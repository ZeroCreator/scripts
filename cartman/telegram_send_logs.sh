#!/bin/bash

#--------------------------------------------------------------------
# Script for sending logs to telegram
# Скрипт для отправки логов в telegram-канал
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

require_vars LOG_FILE CONTAINER_NAME

# Отправка содержимого лог-файла в Telegram
if [ -f "$LOG_FILE" ]; then
    last_line=""  # Переменная для хранения последней строки
    error_found=false  # Флаг для отслеживания наличия ошибки

    while IFS= read -r line; do
        last_line="$line"  # Сохраняем последнюю строку
        # Проверяем наличие сообщения об ошибке
        if [[ "$line" == *"Ошибка при перезапуске контейнера"* ]]; then
            error_found=true
        fi
    done < "$LOG_FILE"

    log_date=$(echo "$last_line" | awk '{print $1}')  # Извлекаем дату из первой колонки
    current_date=$(date +%Y-%m-%d)  # Получаем текущую дату в формате "YYYY-MM-DD"

    if [ "$log_date" != "$current_date" ]; then
        # Если дата в логе не соответствует текущей дате, отправляем предупреждение
        warning_message="⚠️ Внимание! \nПоследняя запись в логе контейнера $CONTAINER_NAME была сделана \n$log_date, \nа не сегодня ➡️ \n($current_date)."
        # Экранирование символов для MarkdownV2
        warning_message=$(echo -e "$warning_message" | sed 's/[_*`.,-]/\\&/g')
        send_telegram_message "$warning_message" "MarkdownV2"
    else
        # Если последняя запись в логе — ошибка, отправляем её в Telegram
        if $error_found; then
            message_content="ℹ️ $last_line"
            # Экранирование символов для MarkdownV2
            message_content=$(echo -e "$message_content" | sed 's/[_*`.,-]/\\&/g')
            send_telegram_message "$message_content" "MarkdownV2"
        else
            # Если нет ошибок, просто логируем
            echo "$last_line"
        fi
    fi
else
    echo "$(date) Лог-файл $LOG_FILE не найден."
    send_telegram_message "$(date '+%Y-%m-%d %H:%M:%S') ❌ Лог-файл $LOG_FILE не найден."
fi
