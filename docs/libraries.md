# Common Libraries 📚

Общие библиотеки, расположенные в папке `lib/`. Используются всеми модулями проекта.

---

## `lib/common.sh`

Базовая библиотека для всех скриптов.

### `PROJECT_ROOT`
Автоматически определяет корень проекта (родительская папка `lib/`).

### `load_env <path>`
Загружает переменные из `.env` файла.

```bash
load_env "$PROJECT_ROOT/config.env"
load_env "$SCRIPT_DIR/.env"
```

### `require_vars <var1> [var2] ...`
Проверяет, что переменные заданы (не пустые). Если переменная не задана — скрипт завершается с ошибкой.

```bash
require_vars WORKDIR DOCKER_REGISTRY PROJECT_NAME
```

### `log_with_timestamp <message>`
Выводит сообщение с временной меткой.

```bash
log_with_timestamp "Контейнер перезапущен"
# 2025-03-24 14:30:00 - Контейнер перезапущен
```

### `init_log <path>`
Инициализирует лог-файл и перенаправляет `stdout` и `stderr` в него (с дублированием в консоль через `tee`).

```bash
init_log "/var/log/my_script.log"
```

### `handle_error <line> <command>`
Обработчик ошибок для использования с `trap`.

```bash
trap 'handle_error ${LINENO} "${BASH_COMMAND}"' ERR
```

---

## `lib/telegram.sh`

Библиотека для отправки сообщений в Telegram.

> Для работы требует загруженных переменных `TELEGRAM_TOKEN` и `TELEGRAM_CHAT_ID`.

### `send_telegram_message <text> [parse_mode]`
Базовая отправка сообщения.

```bash
# Простое сообщение
send_telegram_message "✅ Всё работает"

# С форматированием MarkdownV2
send_telegram_message "*Жирный* текст" "MarkdownV2"
```

### `send_telegram_message_retry <text> [parse_mode] [max_attempts]`
Отправка с повторными попытками и экспоненциальным backoff (по умолчанию 3 попытки).

```bash
send_telegram_message_retry "❌ Ошибка сборки" "Markdown" 3
```

---

## Шаблон скрипта

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/lib/common.sh"
load_env "$PROJECT_ROOT/config.env"
load_env "$SCRIPT_DIR/.env"
source "$PROJECT_ROOT/lib/telegram.sh"

require_vars MY_VAR1 MY_VAR2

log_with_timestamp "Старт"
send_telegram_message "ℹ️ Скрипт запущен"
```
