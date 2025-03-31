#!/bin/bash

#--------------------------------------------------------------------
# Script for timed restart of Cartman worker in crone
# Скрипт для перезапуска docker-контейнера worker проекта **CARTMAN**
# по времени в crontab ->
# - перезапускает docker-контейнер worker и
# - пишет сообщения в логи LOG_FILE
# Tested on Ubuntu 24.04.1 LTS
# Developed by Olga Shkola in 2025
#--------------------------------------------------------------------

# Переменные для запуска скрипта:
# Имя контейнера
# CONTAINER_NAME="<container_name>"
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
: "${CONTAINER_NAME:?Переменная CONTAINER_NAME не задана}"

# Функция для логирования с временной меткой
log_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Попытка перезапуска контейнера
if docker restart "$CONTAINER_NAME"; then
    message="✅ Контейнер '$CONTAINER_NAME' успешно перезапущен.✈️ "
    log_with_timestamp "$message"
else
    message="❌ Ошибка при перезапуске контейнера '$CONTAINER_NAME'.🤬"
    log_with_timestamp "$message"
fi
