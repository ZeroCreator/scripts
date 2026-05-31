#!/bin/bash

#--------------------------------------------------------------------
# Telegram library for project scripts
# Общая библиотека для отправки сообщений в Telegram
#--------------------------------------------------------------------

require_vars TELEGRAM_TOKEN TELEGRAM_CHAT_ID

# Базовая отправка сообщения в Telegram
# Usage: send_telegram_message "text" [parse_mode]
send_telegram_message() {
    local message="$1"
    local parse_mode="${2:-}"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"

    local curl_opts=(-s -X POST "$url" -d "chat_id=$TELEGRAM_CHAT_ID" --data-urlencode "text=$message")

    if [ -n "$parse_mode" ]; then
        curl_opts+=(-d "parse_mode=$parse_mode")
    fi

    curl "${curl_opts[@]}"
}

# Отправка сообщения с повторными попытками и экспоненциальным backoff
# Usage: send_telegram_message_retry "text" [parse_mode] [max_attempts]
send_telegram_message_retry() {
    local message="$1"
    local parse_mode="${2:-}"
    local max_attempts="${3:-3}"
    local attempt=1
    local wait_time=5

    while [ $attempt -le $max_attempts ]; do
        if send_telegram_message "$message" "$parse_mode" >/dev/null; then
            echo "✅ Сообщение отправлено в Telegram (попытка $attempt)"
            return 0
        else
            echo "⚠️ Ошибка отправки в Telegram (попытка $attempt), повтор через ${wait_time}с..." >&2
            sleep $wait_time
            attempt=$((attempt + 1))
            wait_time=$((wait_time * 2))
        fi
    done

    echo "❌ Не удалось отправить сообщение в Telegram после $max_attempts попыток" >&2
    return 1
}
