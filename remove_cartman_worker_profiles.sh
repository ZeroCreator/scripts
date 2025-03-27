#!/bin/bash

#--------------------------------------------------------------------
# Script to remove /profiles/* from cartman-worker-1
# Скрипт для удаления /profiles/* из docker-контейнера worker проекта **CARTMAN**
# по времени в crontab каждый час ->
# - удаляет /profiles/* 4 REPEAT_COUNT раза из docker-контейнер worker
# Tested on Ubuntu 24.04.1 LTS
# Developed by Olga Shkola in 2025
#--------------------------------------------------------------------

# Количество повторений
REPEAT_COUNT=4

# Выполнение команды
for ((i = 1; i <= REPEAT_COUNT; i++)); do
    echo "$(date '+%Y-%m-%d %H:%M:%S') Запуск команды $i из $REPEAT_COUNT..."
    docker exec cartman-worker-1 rm -rf /profiles/*
done
