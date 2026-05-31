# 🧩 SCRIPTS BLOCKS

1️⃣.  Загрузка переменных окружения через общую библиотеку:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/lib/common.sh"
load_env "$PROJECT_ROOT/config.env"   # общие переменные (Telegram и т.д.)
load_env "$SCRIPT_DIR/.env"           # локальные переменные модуля
```

2️⃣. Подключение библиотеки Telegram и отправка сообщений:

```bash
source "$PROJECT_ROOT/lib/telegram.sh"

# Отправка простого сообщения
send_telegram_message "Текст сообщения"

# Отправка с форматированием MarkdownV2
send_telegram_message "Текст сообщения" "MarkdownV2"

# Отправка с повторными попытками (retry + exponential backoff)
send_telegram_message_retry "Текст сообщения" "Markdown" 3
```

3️⃣. Проверка обязательных переменных:

```bash
require_vars VAR1 VAR2 VAR3
```

4️⃣. Логирование с временной меткой:

```bash
log_with_timestamp "Сообщение для лога"
```

5️⃣. Инициализация лог-файла (перенаправляет stdout и stderr):

```bash
init_log "/path/to/logfile.log"
```

6️⃣. Обработчик ошибок (используется с trap):

```bash
trap 'handle_error ${LINENO} "${BASH_COMMAND}"' ERR
```

7️⃣. Экранирование символов для MarkdownV2:

```bash
message_content=$(echo -e "$message_content" | sed 's/[_*`.,-]/\\&/g')
```

8️⃣. Формат времени:

получить текущую дату в формате "YYYY-MM-DD H:M:S"

`$(date '+%Y-%m-%d %H:%M:%S')`

или получить текущую дату в формате "YYYY-MM-DD"

`$(date '+%Y-%m-%d')`
