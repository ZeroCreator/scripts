#!/bin/bash

#--------------------------------------------------------------------
# Script to remove /profiles/* from cartman-worker
# Скрипт для удаления /profiles/* из docker-контейнера worker проекта **CARTMAN**
# по времени в crontab каждый час ->
# - удаляет /profiles/* REPEAT_COUNT раза из docker-контейнер worker
# - отправляет сообщение в telegram
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

# Количество повторений
REPEAT_COUNT=4

# Переменная для хранения сообщений
message_content=""

# Выполнение команды
for ((i = 1; i <= REPEAT_COUNT; i++)); do
    echo "$(date '+%Y-%m-%d %H:%M:%S') Запуск команды $i из $REPEAT_COUNT..."

    # Получение размера профилей перед удалением
    size_before=$(docker exec cartman-worker-1 bash -c 'du -sh /profiles | cut -f1')

    # Удаление профилей
    docker exec cartman-worker-1 bash -c 'rm -rf /profiles/*'

    # Получение размера профилей после удаления
    size_after=$(docker exec cartman-worker-1 bash -c 'du -sh /profiles | cut -f1')

    # Отправка сообщения в консоль
    echo -e "Запуск $i из $REPEAT_COUNT: Размер профилей до удаления: $size_before, после удаления: $size_after"

    # Формирование сообщения
    message_content+="Запуск $i из $REPEAT_COUNT: Размер профилей до удаления: $size_before, после удаления: $size_after\n"
done

# Экранирование символов для MarkdownV2
message_content=$(echo -e "$message_content" | sed 's/[_*`.,-]/\\&/g')

# Отправка сообщения в Telegram
send_telegram_message "$message_content" "MarkdownV2"
