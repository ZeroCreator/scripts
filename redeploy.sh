#!/bin/sh

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
# Имя проекта ->
# PROJECT_NAME
# Конфигурационный файл, где хранятся все переменные ->
# CONFIG_FILE


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
: "${TELEGRAM_TOKEN:?Переменная TELEGRAM_TOKEN не задана}"
: "${TELEGRAM_CHAT_ID:?Переменная TELEGRAM_CHAT_ID не задана}"
: "${WORKDIR:?Переменная WORKDIR не задана}"
: "${PROJECT_NAME:?Переменная PROJECT_NAME не задана}"

# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
         -d chat_id="$TELEGRAM_CHAT_ID" \
         -d text="$message" \
         -d parse_mode="Markdown"
}

# Функция для вывода сообщений об ошибках
error_exit() {
    echo "Ошибка: $1" >&2
    exit 1
}

# Функция для вывода звездочек:
print_stars() {
    for i in {1..2}; do
        echo "*"
    done
}

print_stars
echo "-*-*-*-START-*-*-*-"
send_telegram_message "ℹ️  Запуск скрипта проекта $PROJECT_NAME: $(date)"
print_stars

# Вывод даты и времени начала выполнения скрипта
echo "Скрипт запущен: $(date)"
print_stars

# Переход в директорию
echo "Переходим в директорию $WORKDIR:"
echo "Текущая директория: $(pwd)"
echo "Содержимое родительской директории: $(ls ..)"

cd $WORKDIR || error_exit "Не удалось перейти в директорию $WORKDIR"

echo "Перешли в директорию $WORKDIR."
print_stars

# Удаление образа Docker
echo "Удаляем образ docker-registry.km-union.ru/$PROJECT_NAME:"

if docker rmi docker-registry.km-union.ru/$PROJECT_NAME; then
    echo "Образ docker-registry.km-union.ru/$PROJECT_NAME успешно удален."
else
    echo "Образ docker-registry.km-union.ru/$PROJECT_NAME не найден или не удалось удалить."
fi
print_stars

# Сборка образов
echo "Начинаем сборку образа $PROJECT_NAME:"

if docker compose build; then
    echo "Образ $PROJECT_NAME успешно собран." 
    send_telegram_message "ℹ️  Образ $PROJECT_NAME успешно собран."
else
    error_exit "Ошибка при сборке образа $PROJECT_NAME."
    send_telegram_message "❌ Ошибка при сборке образа $PROJECT_NAME."
fi
print_stars

# Публикация образа
echo "Публикуем образ $PROJECT_NAME в docker-registry:"

if docker push docker-registry.km-union.ru/$PROJECT_NAME:latest; then
    echo "Образ docker-registry.km-union.ru/$PROJECT_NAME:latest успешно опубликован."
    send_telegram_message "ℹ️  Образ docker-registry.km-union.ru/$PROJECT_NAME:latest успешно опубликован."
else
    error_exit "Ошибка при публикации образа: docker-registry.km-union.ru/$PROJECT_NAME:latest."
    send_telegram_message "❌ Ошибка при публикации образа: docker-registry.km-union.ru/$PROJECT_NAME:latest."
fi
print_stars

# Вывод даты и времени завершения выполнения скрипта
echo "Скрипт проекта $PROJECT_NAME завершен: $(date)"
print_stars

echo "Скрипт выполнен успешно!"

print_stars
echo ":) END :)"
send_telegram_message "✅ Скрипт проекта $PROJECT_NAME успешно выполнен: $(date)!"
print_stars

# Логирование
exec > >(tee -i "$LOGDIR/$PROJECT_NAME.logs") 2>&1
