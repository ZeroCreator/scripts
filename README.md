# scripts


## 1. **Script to Deployment Projects**

Данный Скрипт ->
- переходит в рабочую директорию проекта, 
- удаляет старый образ,
- собирает новый образ, 
- публикует его в docker-registry и 
- отправляет сообщения в telegram-канал

**Переменные для запуска скрипта**:
_Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`
_Директория, где будет собираться образ_ - `WORKDIR="/path/to/workdir/"`
_Имя проекта_ - `PROJECT_NAME="<project_name>"`

## **Script for timed restart of Cartman worker in crone**

Данный Скрипт ->
- перезапускает docker-контейнер `CONTAINER_NAME` и
- пишет сообщения в логи `LOG_FILE`

**Переменные для запуска скрипта**:
_Имя контейнера_ - `CONTAINER_NAME="<container_name>"`
_Путь до LOG_FILE_ - `LOG_FILE="/path/to/logs/"`
