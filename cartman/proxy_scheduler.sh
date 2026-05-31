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

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/lib/common.sh"
load_env "$PROJECT_ROOT/config.env"
load_env "$SCRIPT_DIR/.env"
source "$PROJECT_ROOT/lib/telegram.sh"

require_vars DATE_FILE PAST_DATE MESSAGE

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
