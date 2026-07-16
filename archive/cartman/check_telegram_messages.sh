#!/bin/bash

#--------------------------------------------------------------------
# Script to check telegram messages
# Скрипт для проверки аудита ->
# - получает время файла последнего аудита,
# - проверяет, что файл был сформирован не позднее TIME_DELTA,
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

require_vars TIMESTAMP_HOST_FILE TIME_DELTA

# Проверка существования файла
if [ ! -f "$TIMESTAMP_HOST_FILE" ]; then
    send_telegram_message "❌ FATAL!!! 🤬 $(date '+%Y-%m-%d %H:%M:%S') - Файл $TIMESTAMP_HOST_FILE не найден."
    exit 1
fi

# Получение времени последнего изменения файла
last_modified_time=$(stat -c %Y "$TIMESTAMP_HOST_FILE")
current_time=$(date +%s)

# Проверка времени
if (( (current_time - last_modified_time) > (TIME_DELTA * 3600) )); then
    echo "FATAL!!! $(date '+%Y-%m-%d %H:%M:%S') - Не было сообщений о работе грабберов за $TIME_DELTA ч."
    send_telegram_message "❌ FATAL!!! 🤬 $(date '+%Y-%m-%d %H:%M:%S') - Не было сообщений о работе грабберов за $TIME_DELTA ч."
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Проверка аудита грабберов завершена успешно. Сообщения были отправлены."
send_telegram_message "✅ $(date '+%Y-%m-%d %H:%M:%S') - Проверка аудита грабберов завершена успешно. 🔔 Сообщения были отправлены в чаты.✈️ "
