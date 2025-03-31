#!/bin/bash

#--------------------------------------------------------------------
# Script for sending logs to telegram
# Скрипт для отправки логов в telegram-канал
# Tested on Ubuntu 24.04.1 LTS
# Developed by Olga Shkola in 2025
#--------------------------------------------------------------------

# Переменные для запуска скрипта:
# Токен и ID телеграм-канала ->
# TELEGRAM_TOKEN
# TELEGRAM_CHAT_ID
# Путь до LOG_FILE ->
# LOG_FILE="/path/to/logs/"
# Название контейнера
# CONTAINER_NAME
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
: "${LOG_FILE:?Переменная LOG_FILE не задана}"
: "${CONTAINER_NAME:?Переменная CONTAINER_NAME не задана}"

# Проверка наличия переменной окружения с токеном Telegram
if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Ошибка: Не установлены переменные окружения TELEGRAM_TOKEN или TELEGRAM_CHAT_ID." >&2
    exit 1
fi

# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message="$1"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"
    curl -s -X POST "$url" \
            --data-urlencode "chat_id=$TELEGRAM_CHAT_ID" \
            --data-urlencode "text=$message" \
            --data-urlencode "parse_mode=MarkdownV2"
}

# Отправка содержимого лог-файла в Telegram
if [ -f "$LOG_FILE" ]; then
    last_line=""  # Переменная для хранения последней строки
    while IFS= read -r line; do
        last_line="$line"  # Сохраняем последнюю строку
    done < "$LOG_FILE"

    message_content="ℹ️  Последняя запись в логе рестарта контейнера - $CONTAINER_NAME:\n $last_line"

    # Экранирование символов для MarkdownV2
    message_content=$(echo -e "$message_content" | sed 's/[_*`.,-]/\\&/g')

    echo "$message_content"
    send_telegram_message "$message_content"
else
    echo "$(date) Restart $CONTAINER_NAME не был произведен. Лог-файл $LOG_FILE не найден."
    send_telegram_message "$(date) ❌ Restart $CONTAINER_NAME не был произведен. ⚠️  Лог-файл $LOG_FILE не найден. 🔔"
fi

