#!/bin/bash

#--------------------------------------------------------------------
# Script for timed restart of docker container in crone
# Скрипт для перезапуска docker-контейнера по времени в crontab ->
# - перезапускает docker-контейнер CONTAINER_NAME и
# - пишет сообщения в логи LOG_FILE
# Tested on Ubuntu 24.04.1 LTS
# Developed by Olga Shkola in 2025
#--------------------------------------------------------------------

# Переменные для запуска скрипта:
# Имя контейнера
# CONTAINER_NAME="<container_name>"
# Путь до LOG_FILE
# LOG_FILE="/path/to/logs/"
# Конфигурационный файл, где хранятся все переменные ->
# CONFIG_FILE

# Время задержки отправки сообщения в telegram
# Задержка на 2 часа (7200 секунд)
# Задержка на 2,5 часа (9000 секунд)
# Задержка на 3 часа (10800 секунд)


TIME_SLEEP=10800
TIME_SLEEP_MESSAGE=3
TIME_SLEEP_ERROR=7200

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
: "${TIMESTAMP_HOST_FILE:?Переменная TIMESTAMP_HOST_FILE не задана}"
: "${TIME_DELTA:?Переменная TIME_DELTA не задана}"

# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message="$1"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"
    curl -s -X POST "$url" -d "chat_id=$TELEGRAM_CHAT_ID&text=$message"
}

# Функция для логирования с временной меткой
log_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Попытка перезапуска контейнера
if docker restart "$CONTAINER_NAME"; then
    message="✅ Контейнер '$CONTAINER_NAME' успешно перезапущен.✈️ "
    log_with_timestamp "$message"

    # Задержка на 3 часа (10800 секунд)
    sleep $TIME_SLEEP

    # Отправка сообщения о завершении перезапуска
    message="✅ Контейнер '$CONTAINER_NAME' был перезапущен ✈️  и работает уже $TIME_SLEEP_MESSAGE часа."
    log_with_timestamp "$message"
    send_telegram_message "$message" &  # Отправка в фоновом режиме

else
    message="❌ Ошибка при перезапуске контейнера '$CONTAINER_NAME'.🤬"
    log_with_timestamp "$message"

    # Задержка на 2 часа (7200 секунд)
    sleep $TIME_SLEEP_ERROR

    send_telegram_message "$message" &  # Отправка в фоновом режиме
fi
