#!/bin/bash

#--------------------------------------------------------------------
# Script to remove /profiles/* from cartman-worker
# Скрипт для удаления /profiles/* из docker-контейнера worker проекта **CARTMAN**
# по времени в crontab каждый час ->
# - удаляет /profiles/* 4 REPEAT_COUNT раза из docker-контейнер worker
# - отправляет сообщение в telegram
# Tested on Ubuntu 24.04.1 LTS
# Developed by Olga Shkola in 2025
#--------------------------------------------------------------------

# Количество повторений
REPEAT_COUNT=4

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

# Проверка наличия переменной окружения с токеном Telegram
if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Ошибка: Не установлены переменные окружения TELEGRAM_TOKEN или TELEGRAM_CHAT_ID." >&2
    exit 1
fi

# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message="$1"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"
    curl -s -X POST "$url" \
            --data-urlencode "chat_id=$TELEGRAM_CHAT_ID" \
            --data-urlencode "text=$message" \
            --data-urlencode "parse_mode=MarkdownV2"
}

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
send_telegram_message "$message_content"
