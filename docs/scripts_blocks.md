# 🧩 SCRIPTS BLOCKS

1️⃣.  Подключение переменных окружения:

```bash
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
: "${VARIABLE_ONE:?Переменная VARIABLE_ONE не задана}"
: "${VARIABLE_TWO:?Переменная VARIABLE_TWO не задана}"
```

---
2️⃣. Отправка сообщений в telegram:

```bash
# Проверка наличия переменной окружения с токеном Telegram
if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Ошибка: Не установлены переменные окружения TELEGRAM_TOKEN или TELEGRAM_CHAT_ID." >&2
    exit 1
fi

# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message="$1"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"
    curl -s -X POST "$url" -d "chat_id=$TELEGRAM_CHAT_ID&text=$message"
}

# Переменная для хранения сообщений
message_content=""

send_telegram_warning_message "$message_content"
```

---
3️⃣.  Отправка telegram-сообщений с форматированием:

```bash
# Функция для отправки сообщения в Telegram с повторными попытками
send_telegram_message() {
    local message="$1"
    local max_attempts=3
    local attempt=1
    local wait_time=5
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
             -d chat_id="$TELEGRAM_CHAT_ID" \
             -d text="$message" \
             -d parse_mode="Markdown" \
             --connect-timeout 10 \
             --max-time 30; then
            echo "✅ Сообщение отправлено в Telegram (попытка $attempt)"
            return 0
        else
            echo "⚠️ Ошибка отправки в Telegram (попытка $attempt), повтор через ${wait_time}с..."
            sleep $wait_time
            attempt=$((attempt + 1))
            wait_time=$((wait_time * 2))  # Exponential backoff
        fi
    done
    
    echo "❌ Не удалось отправить сообщение в Telegram после $max_attempts попыток"
    return 1
}
```

---
4️⃣.  Экранирование символов для MarkdownV2:

message_content=$(echo -e "$message_content" | sed 's/[_*`.,-]/\\&/g')

---

5️⃣.  Формат времени:

получить текущую дату в формате "YYYY-MM-DD H:M:S"

`$(date '+%Y-%m-%d %H:%M:%S')`

или получить текущую дату в формате "YYYY-MM-DD"

`$(date '+%Y-%m-%d')`