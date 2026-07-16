#!/bin/bash
# Отправка сообщений ARMory в Telegram.
# Используется планировщиком ARMory для рассылки отчётов и уведомлений.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$(cd "$PROJECT_ROOT/../lib" && pwd)"

# shellcheck source=/dev/null
source "$LIB_DIR/common.sh"

MESSAGE_FILE="${1:-}"
ENV_FILE="${2:-$PROJECT_ROOT/.env}"
PARSE_MODE="${3:-}"

if [ -z "$MESSAGE_FILE" ]; then
    echo "Usage: $0 <path-to-message-file> [path-to-env-file] [parse_mode]" >&2
    exit 1
fi

if [ ! -f "$MESSAGE_FILE" ]; then
    echo "Message file not found: $MESSAGE_FILE" >&2
    exit 1
fi

load_env "$ENV_FILE"

# ARMory использует TELEGRAM_BOT_TOKEN, общая библиотека — TELEGRAM_TOKEN
TOKEN="${TELEGRAM_BOT_TOKEN:-${TELEGRAM_TOKEN:-}}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"

require_vars TOKEN CHAT_ID

MAX_LEN=4000
API_URL="https://api.telegram.org/bot${TOKEN}/sendMessage"

send_chunk() {
    local text="$1"
    # Убираем trailing whitespace/newlines
    text="${text%"${text##*[![:space:]]}"}"
    if [ -z "$text" ]; then
        return
    fi

    local curl_opts=(
        -sS --max-time 30 -X POST "$API_URL"
        -d "chat_id=${CHAT_ID}"
        --data-urlencode "text=${text}"
        -d "disable_web_page_preview=true"
    )
    if [ -n "$PARSE_MODE" ]; then
        curl_opts+=(-d "parse_mode=${PARSE_MODE}")
    fi

    local response
    if ! response=$(curl "${curl_opts[@]}" 2>&1); then
        echo "Failed to send Telegram request: $response" >&2
        exit 1
    fi
    if echo "$response" | grep -q '"ok":false'; then
        echo "Telegram API error: $response" >&2
        exit 1
    fi
}

chunk=""
while IFS= read -r line || [ -n "$line" ]; do
    line="$line"$'\n'
    if [ $((${#chunk} + ${#line})) -gt $MAX_LEN ]; then
        send_chunk "$chunk"
        chunk=""
    fi
    chunk="${chunk}${line}"
done < "$MESSAGE_FILE"
send_chunk "$chunk"

echo "Sent ARMory message from $MESSAGE_FILE to Telegram chat $CHAT_ID"
