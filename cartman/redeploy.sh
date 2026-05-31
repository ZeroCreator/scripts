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

set -eEuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/lib/common.sh"
load_env "$PROJECT_ROOT/config.env"
load_env "$SCRIPT_DIR/.env"
source "$PROJECT_ROOT/lib/telegram.sh"

require_vars WORKDIR DOCKER_REGISTRY PROJECT_NAME

# --- Блок с SSH-агентом ---
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

# Инициализация лог-файла
LOG_FILE="${LOGDIR:-/tmp}/${PROJECT_NAME}_$(date '+%Y%m%d_%H%M%S').log"
init_log "$LOG_FILE"

# Устанавливаем обработчики ошибок
trap 'handle_error ${LINENO} "${BASH_COMMAND}"' ERR

# Основной код скрипта
echo "-*-*-*-START-*-*-*-"
send_telegram_message_retry "ℹ️ Запуск скрипта проекта ${PROJECT_NAME}: $(date '+%Y-%m-%d %H:%M:%S')" "" 3

echo "Скрипт запущен: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Переходим в директорию ${WORKDIR}"

cd "${WORKDIR}" || {
    error_msg="❌ Не удалось перейти в директорию ${WORKDIR}"
    echo "${error_msg}" >&2
    send_telegram_message_retry "${error_msg}" "" 3
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
    send_telegram_message_retry "ℹ️ Образ ${PROJECT_NAME} успешно собран" "" 3
else
    error_msg="❌ Ошибка сборки образа ${PROJECT_NAME}"
    echo "${error_msg}" >&2
    send_telegram_message_retry "${error_msg}" "" 3
    exit 1
fi

# Публикация образа
echo "Публикация образа ${DOCKER_REGISTRY}/${PROJECT_NAME}:latest"
if docker push "${DOCKER_REGISTRY}/${PROJECT_NAME}:latest"; then
    echo "Образ успешно опубликован"
    send_telegram_message_retry "ℹ️ Образ ${PROJECT_NAME} успешно опубликован" "" 3
else
    error_msg="❌ Ошибка публикации образа ${PROJECT_NAME}"
    echo "${error_msg}" >&2
    send_telegram_message_retry "${error_msg}" "" 3
    exit 1
fi

# Успешное завершение
send_telegram_message_retry "✅ Скрипт проекта ${PROJECT_NAME} успешно выполнен: $(date '+%Y-%m-%d %H:%M:%S')" "" 3
echo "Скрипт завершен успешно"
exit 0
