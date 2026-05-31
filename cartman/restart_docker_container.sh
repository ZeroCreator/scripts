#!/bin/bash

#--------------------------------------------------------------------
# Script for timed restart of docker container in crone
# Скрипт для перезапуска docker-контейнера по времени в crontab ->
# - перезапускает docker-контейнер CONTAINER_NAME и
# - пишет сообщения в логи LOG_FILE
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

require_vars CONTAINER_NAME LOG_FILE

TIME_SLEEP=10800
TIME_SLEEP_MESSAGE=3
TIME_SLEEP_ERROR=7200

# Попытка перезапуска контейнера
if docker restart "$CONTAINER_NAME"; then
    message="✅ Контейнер '$CONTAINER_NAME' успешно перезапущен.✈️ "
    log_with_timestamp "$message"

    # Задержка на 3 часа (10800 секунд)
    sleep $TIME_SLEEP

    # Отправка сообщения о завершении перезапуска
    message="✅ Контейнер '$CONTAINER_NAME' был перезапущен ✈️  и работает уже $TIME_SLEEP_MESSAGE часа."
    log_with_timestamp "$message"
    send_telegram_message "$message" &  # Отправка в фоновом режиме

else
    message="❌ Ошибка при перезапуске контейнера '$CONTAINER_NAME'.🤬"
    log_with_timestamp "$message"

    # Задержка на 2 часа (7200 секунд)
    sleep $TIME_SLEEP_ERROR

    send_telegram_message "$message" &  # Отправка в фоновом режиме
fi
