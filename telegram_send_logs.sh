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


# Проверка наличия переменной окружения с токеном Telegram
if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Ошибка: Не установлены переменные окружения TELEGRAM_TOKEN или TELEGRAM_CHAT_ID." >&2
    exit 1
fi

# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message="$1"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"
    curl -s -X POST "$url" -d "chat_id=$TELEGRAM_CHAT_ID&text=$message"
}

# Отправка содержимого лог-файла в Telegram
if [ -f "$LOG_FILE" ]; then
    while IFS= read -r line; do
        send_telegram_message "$line"
    done < "$LOG_FILE"
    echo "Все логи $LOG_FILE успешно отправлены в Telegram: $(date)"
else
    echo "$(date) ❌ Лог-файл не найден ❌"
    send_telegram_message "$(date) Лог-файл $LOG_FILE не найден."
fi
