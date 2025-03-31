# SCRIPTS

## 1. **Script to Deployment Projects** (_redeploy.sh_)

**Скрипт для деплоя проектов** ->
- переходит в рабочую директорию проекта, 
- удаляет старый образ,
- собирает новый образ, 
- публикует его в docker-registry и 
- отправляет сообщения в telegram

**Переменные для запуска скрипта**:
- _Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`
- _Директория, где будет собираться образ_ - `WORKDIR="/path/to/workdir/"`
- _Директория docker-registry_ - `DOCKER_REGISTRY`
- _Имя проекта_ - `PROJECT_NAME`
- _Конфигурационный файл, где хранятся все переменные_ - `CONFIG_FILE`

Пример запуск по времени деплоя проекта:
```bash
echo "/path/to/scripts/redeploy.sh /path/to/scripts/config.env >> /path/to/scripts/cartman_log.log 2>&1" | at 18:26 2025-03-24
```

---
## 2. **Script to check Cartman Project audit** (_check_telegram_messages.sh_)

**Скрипт для проверки было ли отправлено сообщение в telegram** ->
- получает время отправки последнего сообщения,
- проверяет, что сообщение было сформировано не позднее `TIME_DELTA`,
- отправляет сообщения о результатах в telegram

**Переменные для запуска скрипта**:
- _Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`
- _Имя и путь до файла, где будет храниться время последнего сообщения об аудите_ - `TIMESTAMP_HOST_FILE`
- _Время, за которое ищется сообщение об аудите_ - `TIME_DELTA`
- _Конфигурационный файл, где хранятся все переменные_ - `CONFIG_FILE`

Пример запуска скрипта в **crontab**:
```bash
0 9 * * * /path/to/scripts/check_telegram_messages.sh /path/to/scripts/config.env >> /path/to/scripts/check_telegram_messages.log 2>&1
```

---
## 3. **Script for timed restart of docker container in crone** (_restart_docker_container.sh_)

**Скрипт для перезапуска docker-контейнера по времени в crontab** ->
- перезапускает docker-контейнер `CONTAINER_NAME` и
- пишет сообщения в логи `LOG_FILE`

**Переменные для запуска скрипта**:
- _Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`
- _Имя контейнера_ - `CONTAINER_NAME`
- _Путь до LOG_FILE_ - `LOG_FILE="/path/to/logs/"`
- _Конфигурационный файл, где хранятся все переменные_ - `CONFIG_FILE`

Частный случай - скрипт **Script for timed restart of Cartman worker in crone** (_restart_cartman_worker.sh_) 
перезапускает docker-контейнер **worker** проекта **Cartman**.

Пример запуска скрипта для проекта **Cartman** в **crontab**:
```bash
0 6 * * * /path/to/scripts/restart_cartman_worker.sh /path/to/scripts/config.env >> /path/to/scripts/restart_cartman_worker.log 2>&1
```

---
## 4. **Script for sending logs to telegram** (_telegram_send_logs.sh_)

**Скрипт для отправки логов в telegram-канал**
- отправляет последнюю запись из LOG_FILE в telegram

**Переменные для запуска скрипта**:
- _Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`
- _Путь до LOG_FILE_ - `LOG_FILE="/path/to/logs/"`
- _Название контейнера_ - `CONTAINER_NAME`
- _Конфигурационный файл, где хранятся все переменные_ - `CONFIG_FILE`

Пример запуска скрипта в **crontab**:
```bash
0 6 * * * /path/to/scripts/telegram_send_logs.sh /path/to/scripts/config.env >> /path/to/scripts/telegram_send_logs.log 2>&1
```

---
## 5. **Script to remove /profiles/ from cartman-worker** (_remove_cartman_worker_profiles.sh_)
**Скрипт для удаления /profiles/ из docker-контейнера worker проекта _CARTMAN_**
- по времени в crontab каждый час удаляет /profiles/* 4 REPEAT_COUNT раза из docker-контейнер worker
- отправляет сообщения в telegram

**Переменные для запуска скрипта**:
- _Токен и ID телеграм-канала_ - `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`

Пример запуска скрипта в **crontab**:
```bash
0 * * * * /path/to/scripts/remove_cartman_worker_profiles.sh /path/to/scripts/config.env >> /path/to/scripts/remove_cartman_worker_profiles.log 2>&1
```

---