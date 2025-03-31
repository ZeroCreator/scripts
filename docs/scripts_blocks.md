# SCRIPTS BLOCKS

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
# Функция для отправки сообщения в Telegram
send_telegram_message() {
    local message="$1"
    local url="https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage"
    curl -s -X POST "$url" \
            --data-urlencode "chat_id=$TELEGRAM_CHAT_ID" \
            --data-urlencode "text=$message" \
            --data-urlencode "parse_mode=MarkdownV2"
}

# Переменная для хранения сообщений
message_content=""

# Экранирование символов для MarkdownV2
message_content=$(echo -e "$message_content" | sed 's/[_*`.,-]/\\&/g')

# Отправка сообщения в Telegram
send_telegram_message "$message_content"
```

---
