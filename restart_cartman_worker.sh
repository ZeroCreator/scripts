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
# Путь до LOG_FILE
# LOG_FILE="/path/to/logs/"


# Функция для логирования с временной меткой
log_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Попытка перезапуска контейнера
if docker restart "$CONTAINER_NAME"; then
    message="✅ Контейнер '$CONTAINER_NAME' успешно перезапущен.✈️ "
    log_with_timestamp "$message"
else
    message="❌ Ошибка при перезапуске контейнера '$CONTAINER_NAME'.🤬"
    log_with_timestamp "$message"
fi
