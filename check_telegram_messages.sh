#!/bin/bash

#--------------------------------------------------------------------
# Script to check Cartman Project audit
# Скрипт для проверки аудита ->
# - получает время файла последнего аудита,
# - проверяет, что файл был сформирован не позднее TIME_DELTA,
# - отправляет сообщения в telegram-канал
# Tested on Ubuntu 24.04.1 LTS
# Developed by Olga Shkola in 2025
#--------------------------------------------------------------------

# Переменные для запуска скрипта:
# Токен и ID телеграм-канала ->
# TELEGRAM_TOKEN
# TELEGRAM_CHAT_ID
# Имя и путь до файла, где будет храниться время последнего
# сообщения об аудите ->
# TIMESTAMP_HOST_FILE
# Время, за которое ищется сообщение об аудите ->
# TIME_DELTA
# Конфигурационный файл, где хранятся все переменные
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
: "${TIMESTAMP_HOST_FILE:?Переменная TIMESTAMP_HOST_FILE не задана}"
: "${TIME_DELTA:?Переменная TIME_DELTA не задана}"

# Функция для отправки сообщения в Telegram
send_telegram_warning_message() {
    local message="$1"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"
    curl -s -X POST "$url" -d "chat_id=$TELEGRAM_CHAT_ID&text=$message"
}

# Проверка существования файла
if [ ! -f "$TIMESTAMP_HOST_FILE" ]; then
    send_telegram_warning_message "❌ FATAL!!! 🤬 Файл $TIMESTAMP_HOST_FILE не найден."
    exit 1
fi

# Получение времени последнего изменения файла
last_modified_time=$(stat -c %Y "$TIMESTAMP_HOST_FILE")
current_time=$(date +%s)

# Проверка времени
if (( (current_time - last_modified_time) > (TIME_DELTA * 3600) )); then
    send_telegram_warning_message "❌ FATAL!!! 🤬 Не было сообщений о работе грабберов за $TIME_DELTA ч."
    exit 1
fi

echo "Проверка аудита грабберов завершена успешно. Сообщения были отправлены."
send_telegram_warning_message "✅  Проверка аудита грабберов завершена успешно. Сообщения были отправлены.✈️ "
