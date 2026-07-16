# ARMory 📬

Модуль для отправки уведомлений и отчётов **ARMory** в Telegram.

Скрипты расположены в `scripts/ARMory/`.

---

## Переменные окружения

Переменные задаются в едином файле `scripts/scripts/.env`:

```dotenv
TELEGRAM_BOT_TOKEN="<telegram-bot-token>"
TELEGRAM_CHAT_ID="<telegram-chat-id>"
```

> Скрипт `send_armory_telegram.sh` понимает как `TELEGRAM_BOT_TOKEN` (формат ARMory), так и `TELEGRAM_TOKEN` (формат общей библиотеки `lib/telegram.sh`).

---

## Скрипты

### `send_armory_telegram.sh`

Отправляет содержимое текстового файла в Telegram. Используется планировщиком ARMory и другими задачами для уведомлений.

**Usage:**
```bash
./scripts/ARMory/send_armory_telegram.sh <path-to-message-file> [path-to-env-file] [parse_mode]
```

**Примеры:**
```bash
# Использовать .env по умолчанию (scripts/scripts/.env)
./scripts/ARMory/send_armory_telegram.sh /tmp/message.txt

# Явно указать .env и MarkdownV2-форматирование
./scripts/ARMory/send_armory_telegram.sh /tmp/message.txt /path/to/.env MarkdownV2
```

**Особенности:**
- длинные сообщения автоматически разбиваются на части по 4000 символов;
- ссылки не превращаются в превью (`disable_web_page_preview=true`);
- путь к `.env` по умолчанию — `scripts/scripts/.env`.

### `send_armory_task_list.py`

Формирует список открытых задач из базы ARMory и отправляет его в Telegram через `send_armory_telegram.sh`. Вызывается планировщиком по задаче `armory-telegram`.

**Переменные окружения:**
- `ARMORY_DB_PATH` — путь к базе ARMory (по умолчанию `~/ARMory/data/armory.db`).

**Запуск вручную:**
```bash
./scripts/ARMory/send_armory_task_list.py
```
