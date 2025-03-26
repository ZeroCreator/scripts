# scripts

Все переменные окружения для скриптов лежат в `config.env` корневой папки `scripts`.

## 1. **Script to Deployment Projects**

**Скрипт для деплоя проектов** ->
- переходит в рабочую директорию проекта, 
- удаляет старый образ,
- собирает новый образ, 
- публикует его в docker-registry и 
- отправляет сообщения в telegram-канал

**Переменные для запуска скрипта**:
- _Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`
- _Директория, где будет собираться образ_ - `WORKDIR="/path/to/workdir/"`
- _Имя проекта_ - `PROJECT_NAME="<project_name>"`
- _Конфигурационный файл, где хранятся все переменные_ - `CONFIG_FILE`

Пример запуск по времени деплоя проекта:
```bash
echo "/path/to/scripts/redeploy.sh /path/to/scripts/config.env >> /path/to/scripts/cartman_log.log 2>&1" | at 18:26 2025-03-24
```


## 2. **Script to check Cartman Project audit**

**Скрипт для проверки аудита** ->
- получает время файла последнего аудита,
- проверяет, что файл был сформирован не позднее `TIME_DELTA`,
- отправляет сообщения в telegram-канал

**Переменные для запуска скрипта**:
- _Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`
- _Имя и путь до файла, где будет храниться время последнего сообщения об аудите_ - `TIMESTAMP_HOST_FILE`
- _Время, за которое ищется сообщение об аудите_ - `TIME_DELTA`
- _Конфигурационный файл, где хранятся все переменные_ - `CONFIG_FILE`

Пример запуска скрипта в crontab:
```bash
0 9 * * * /path/to/scripts/check_telegram_messages.sh /path/to/scripts/config.env >> /path/to/scripts/check_telegram_messages.log 2>&1
```


## 3. **Script for timed restart of docker container in crone**

**Скрипт для перезапуска docker-контейнера по времени в crontab** ->
- перезапускает docker-контейнер `CONTAINER_NAME` и
- пишет сообщения в логи `LOG_FILE`

**Переменные для запуска скрипта**:
- _Имя контейнера_ - `CONTAINER_NAME="<container_name>"`
- _Путь до LOG_FILE_ - `LOG_FILE="/path/to/logs/"`

Частный случай - скрипт **Script for timed restart of Cartman worker in crone** - перезапускает
docker-контейнер worker проекта **Cartman**.

Пример запуска скрипта для проекта **Cartman** в crontab:
```bash
0 6 * * * /path/to/scripts/restart_cartman_worker.sh /path/to/scripts/config.env >> /path/to/scripts/restart_cartman_worker.log 2>&1
```


## 4. **Script for sending logs to telegram**

**Скрипт для отправки логов в telegram-канал**

**Переменные для запуска скрипта**:
- _Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`
- _Путь до LOG_FILE_ - `LOG_FILE="/path/to/logs/"`
- _Конфигурационный файл, где хранятся все переменные_ - `CONFIG_FILE`

Пример запуска скрипта в crontab:
```bash
0 6 * * * /path/to/scripts/telegram_send_logs.sh /path/to/scripts/config.env >> /path/to/scripts/telegram_send_logs.log 2>&1
```


Сделать скрипт исполняемым:
```bash
chmod +x <script_name>.sh
```
