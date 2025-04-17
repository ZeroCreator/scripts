#!/bin/bash

#--------------------------------------------------------------------
# Script **proxy scheduler**
# Скрипт для отправки оповещения о времени оплаты прокси-адресов ->
# - получает первоначальную и текущую даты,
# - проверяет, прошло ли 30 дней,
# - отправляет сообщения в telegram-канал
# Tested on Ubuntu 24.04.1 LTS
# Developed by Olga Shkola in 2025
#--------------------------------------------------------------------

# Переменные для запуска скрипта:
# Токен и ID телеграм-канала ->
# TELEGRAM_TOKEN
# TELEGRAM_CHAT_ID
# Путь до файла с датой ->
# DATE_FILE="/path/to/initial_date.txt"
# Первоначальная дата ->
# PAST_DATE
# Сообщение в telegram ->
# MESSAGE
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
: "${DATE_FILE:?Переменная DATE_FILE не задана}"
: "${PAST_DATE:?Переменная PAST_DATE не задана}"
: "${MESSAGE:?Переменная MESSAGE не задана}"

# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message="$1"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"
    curl -s -X POST "$url" -d "chat_id=$TELEGRAM_CHAT_ID&text=$message"
}

# Проверка, существует ли файл с первоначальной датой
if [ ! -f "$DATE_FILE" ]; then
    # Если файл не существует, задаем первоначальную дату вручную
    echo "$PAST_DATE" > "$DATE_FILE"
    echo "Первоначальная дата установлена: $PAST_DATE."
else
    # Чтение первоначальной даты из файла
    INITIAL_DATE=$(cat "$DATE_FILE")
    echo "Первоначальная дата: $INITIAL_DATE. Сегодня $(date '+%Y-%m-%d %H:%M:%S')."
fi

# Преобразуем дату в формат Unix timestamp
INITIAL_TIMESTAMP=$(date -d "$INITIAL_DATE" +%s)

# Текущая дата в формате Unix timestamp
CURRENT_TIMESTAMP=$(date +%s)

# Проверяем, прошло ли 30 дней (2592000 секунд)
DIFF=$((CURRENT_TIMESTAMP - INITIAL_TIMESTAMP))
if [ "$DIFF" -ge 2592000 ]; then
    send_telegram_message "$MESSAGE"
    # Обновляем дату последней отправки
    echo "$(date +%Y-%m-%d)" > "$DATE_FILE"
    echo "Сообщение отправлено. Обновляем дату последней отправки - $(date +%Y-%m-%d)"
else
    # Рассчитываем количество дней до оплаты proxy
    DAYS_REMAINING=$((30 - (DIFF / 86400)))  # 86400 секунд в сутках
    echo "Осталось $DAYS_REMAINING дней до оплаты proxy."
fi
