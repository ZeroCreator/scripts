#!/bin/bash

#--------------------------------------------------------------------
# Script to Deployment Projects
# Скрипт для деплоя проектов ->
# - переходит в рабочую директорию проекта,
# - удаляет старый образ,
# - собирает новый образ,
# - публикует его в docker-registry и
# - отправляет сообщения в telegram-канал
# Tested on Ubuntu 24.04.1 LTS
# Developed by Olga Shkola in 2025
#--------------------------------------------------------------------

# Переменные для запуска скрипта:
# Токен и ID телеграм-канала ->
# TELEGRAM_TOKEN
# TELEGRAM_CHAT_ID
# Директория, где будет собираться образ ->
# WORKDIR
# Директория docker-registry ->
# DOCKER_REGISTRY
# Имя проекта ->
# PROJECT_NAME
# Конфигурационный файл, где хранятся все переменные ->
# CONFIG_FILE


# Активируем строгий режим (но с осторожностью для SSH_AUTH_SOCK)
set -eEo pipefail

# Загружаем конфиг
CONFIG_FILE="${1:-config}"
source "$CONFIG_FILE" || {
    echo "❌ Failed to load config file"
    exit 1
}

# --- Исправленный блок с SSH-агентом ---
set +u  # Временно разрешаем неопределённые переменные
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
    echo "🔄 Запускаем SSH-агент..."
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa || {
        echo "❌ Не удалось добавить SSH-ключ"
        exit 1
    }
    export SSH_AUTH_SOCK
fi
set -u  # Возвращаем строгий режим
# --------------------------------------

# Проверка наличия аргумента
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 путь_к_конфигурационному_файлу" >&2
    exit 1
fi

CONFIG_FILE="$1"

# Загрузка переменных из файла конфигурации
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "Файл конфигурации $CONFIG_FILE не найден." >&2
    exit 1
fi

# Проверка обязательных переменных
for var in TELEGRAM_TOKEN TELEGRAM_CHAT_ID WORKDIR DOCKER_REGISTRY PROJECT_NAME; do
    if [ -z "${!var}" ]; then
        echo "Переменная $var не задана" >&2
        exit 1
    fi
done

# Функция для отправки сообщения в Telegram
# Функция для отправки сообщения в Telegram с повторными попытками
send_telegram_message() {
    local message="$1"
    local max_attempts=3
    local attempt=1
    local wait_time=5

    while [ $attempt -le $max_attempts ]; do
        if curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
             -d chat_id="$TELEGRAM_CHAT_ID" \
             -d text="$message" \
             -d parse_mode="Markdown" \
             --connect-timeout 10 \
             --max-time 30; then
            echo "✅ Сообщение отправлено в Telegram (попытка $attempt)"
            return 0
        else
            echo "⚠️ Ошибка отправки в Telegram (попытка $attempt), повтор через ${wait_time}с..."
            sleep $wait_time
            attempt=$((attempt + 1))
            wait_time=$((wait_time * 2))  # Exponential backoff
        fi
    done

    echo "❌ Не удалось отправить сообщение в Telegram после $max_attempts попыток"
    return 1
}

# Инициализация лог-файла
LOG_FILE="${LOGDIR:-/tmp}/${PROJECT_NAME}_$(date '+%Y%m%d_%H%M%S').log"
exec 3>&1 4>&2
exec > >(tee -a "${LOG_FILE}") 2>&1

# Функция обработки ошибок
handle_error() {
    local exit_code=$?
    local line_number=$1
    local command=$2

    error_message="❌ [Сбой] Проект: ${PROJECT_NAME}
Ошибка в строке ${line_number}: ${command}
Код ошибки: ${exit_code}
Директория: $(pwd)
Время: $(date '+%Y-%m-%d %H:%M:%S')
Логи: ${LOG_FILE}"

    echo "${error_message}" >&2
    send_telegram_message "${error_message}"
    exit ${exit_code}
}

# Устанавливаем обработчики ошибок
trap 'handle_error ${LINENO} "${BASH_COMMAND}"' ERR
set -eEuo pipefail

# Основной код скрипта
echo "-*-*-*-START-*-*-*-"
send_telegram_message "ℹ️ Запуск скрипта проекта ${PROJECT_NAME}: $(date '+%Y-%m-%d %H:%M:%S')"

echo "Скрипт запущен: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Переходим в директорию ${WORKDIR}"

cd "${WORKDIR}" || {
    error_msg="❌ Не удалось перейти в директорию ${WORKDIR}"
    echo "${error_msg}" >&2
    send_telegram_message "${error_msg}"
    exit 1
}

echo "Директория изменена на: $(pwd)"

# Переименование образа
IMAGE_ID=$(docker images -q "${DOCKER_REGISTRY}/${PROJECT_NAME}:latest")
if [ -n "${IMAGE_ID}" ]; then
    CREATION_DATE=$(docker inspect --format='{{.Created}}' "${IMAGE_ID}")
    NEW_TAG="${DOCKER_REGISTRY}/${PROJECT_NAME}:$(date -d "${CREATION_DATE}" '+%Y-%m-%d-%H-%M-%S')"

    if docker tag "${IMAGE_ID}" "${NEW_TAG}"; then
        echo "Образ переименован: ${NEW_TAG}"
    else
        echo "⚠️ Не удалось переименовать образ" >&2
    fi
fi

# Сборка образа
echo "Начинаем сборку образа ${PROJECT_NAME}"
# Проверяем, запущен ли SSH-агент
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    export SSH_AUTH_SOCK
fi

if docker compose build --no-cache; then
    echo "Сборка успешно завершена"
    send_telegram_message "ℹ️ Образ ${PROJECT_NAME} успешно собран"
else
    error_msg="❌ Ошибка сборки образа ${PROJECT_NAME}"
    echo "${error_msg}" >&2
    send_telegram_message "${error_msg}"
    exit 1
fi

# Публикация образа
echo "Публикация образа ${DOCKER_REGISTRY}/${PROJECT_NAME}:latest"
if docker push "${DOCKER_REGISTRY}/${PROJECT_NAME}:latest"; then
    echo "Образ успешно опубликован"
    send_telegram_message "ℹ️ Образ ${PROJECT_NAME} успешно опубликован"
else
    error_msg="❌ Ошибка публикации образа ${PROJECT_NAME}"
    echo "${error_msg}" >&2
    send_telegram_message "${error_msg}"
    exit 1
fi

# Успешное завершение
send_telegram_message "✅ Скрипт проекта ${PROJECT_NAME} успешно выполнен: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Скрипт завершен успешно"
exit 0
