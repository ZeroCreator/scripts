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
# Путь до LOG_FILE
# LOG_FILE="/path/to/logs/"

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
else
    send_telegram_message "Лог-файл не найден."
fi
