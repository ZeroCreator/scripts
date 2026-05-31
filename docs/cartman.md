# Cartman 🚀

Модуль скриптов для DevOps-сопровождения проекта **Cartman**.

---

## Переменные окружения

Файл `cartman/.env`:

```dotenv
# Переменные проекта
WORKDIR=Cartman/cartman
LOGDIR=Cartman/scripts
PROJECT_NAME=cartman

# Для скрипта redeploy
DOCKER_REGISTRY="docker-registry.km-union.ru"

# Для скрипта restart_docker_container / telegram_send_logs
LOG_FILE="/home/grabber/scripts/restart_cartman_worker.log"
CONTAINER_NAME="cartman-worker-1"

# Для скрипта check_telegram_messages
TIMESTAMP_HOST_FILE="/home/grabber/cartman/_media/cartman_timestamp_file.txt"
TIME_DELTA=24

# Для скрипта proxy_scheduler
DATE_FILE="/home/korallmicro/scripts/initial_date.txt"
MESSAGE="🔔 Пора оплачивать прокси!"
PAST_DATE="2025-03-19"
```

---

## Скрипты

### 1. `redeploy.sh`

Деплой проекта:
- переходит в рабочую директорию,
- переименовывает тег старого образа датой создания,
- собирает новый образ `latest`,
- публикует в docker-registry,
- отправляет уведомления в Telegram.

**Переменные**: `WORKDIR`, `DOCKER_REGISTRY`, `PROJECT_NAME`, `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`

**Пример `at`:**
```bash
echo "/path/to/scripts/cartman/redeploy.sh >> /path/to/scripts/cartman_log.log 2>&1" | at 18:26 2025-03-24
```

---

### 2. `check_telegram_messages.sh`

Проверка аудита:
- получает время последнего аудита из `TIMESTAMP_HOST_FILE`,
- проверяет, что файл обновлялся не позднее `TIME_DELTA` часов,
- отправляет результат в Telegram.

**Переменные**: `TIMESTAMP_HOST_FILE`, `TIME_DELTA`

**Пример `crontab`:**
```bash
0 9 * * * /path/to/cartman/check_telegram_messages.sh >> /path/to/cartman/check_telegram_messages.log 2>&1
```

---

### 3. `restart_docker_container.sh`

Перезапуск docker-контейнера с логированием и уведомлением в Telegram.

**Переменные**: `CONTAINER_NAME`, `LOG_FILE`

**Пример `crontab`:**
```bash
0 6 * * * /path/to/cartman/restart_docker_container.sh >> /path/to/cartman/restart_docker_container.log 2>&1
```

---

### 4. `restart_cartman_worker.sh`

Перезапуск контейнера `cartman-worker`.

**Переменные**: `CONTAINER_NAME`

**Пример `crontab`:**
```bash
0 6 * * * /path/to/cartman/restart_cartman_worker.sh >> /path/to/cartman/restart_cartman_worker.log 2>&1
```

---

### 5. `telegram_send_logs.sh`

Отправка последней записи из `LOG_FILE` в Telegram.

**Переменные**: `LOG_FILE`, `CONTAINER_NAME`

**Пример `crontab`:**
```bash
0 6 * * * /path/to/cartman/telegram_send_logs.sh >> /path/to/cartman/telegram_send_logs.log 2>&1
```

---

### 6. `remove_cartman_worker_profiles.sh`

Удаление `/profiles/*` из контейнера `cartman-worker`.
- выполняет удаление `REPEAT_COUNT` раз,
- отправляет статистику в Telegram.

**Переменные**: `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`

**Пример `crontab`:**
```bash
0 * * * * /path/to/cartman/remove_cartman_worker_profiles.sh >> /path/to/cartman/remove_cartman_worker_profiles.log 2>&1
```

---

### 7. `proxy_scheduler.sh`

Напоминание об оплате прокси:
- отслеживает дату последней оплаты в `DATE_FILE`,
- если прошло 30 дней — отправляет сообщение в Telegram.

**Переменные**: `DATE_FILE`, `PAST_DATE`, `MESSAGE`

**Пример `crontab`:**
```bash
0 10 * * * /path/to/cartman/proxy_scheduler.sh >> /path/to/cartman/proxy_scheduler.log 2>&1
```
