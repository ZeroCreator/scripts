# ВВЕДЕНИЕ

```
SSSSSSS    CCCCCC   RRRRRR    IIIII   PPPPPP   TTTTTTT  SSSSSSS
S         C         R     R     I     P     P     T     S
 SSSSS    C         RRRRRR      I     PPPPPP      T      SSSSS
      S   C         R   R       I     P           T           S
SSSSSSS    CCCCCC   R    R    IIIII   P           T     SSSSSSS
``` 

🚀 **Scripts** — монорепозиторий вспомогательных скриптов для DevOps-сопровождения проектов.

---

## Модули

| Модуль | Описание | Документация |
|---|---|---|
| `scripts/ARMory/` | Отправка уведомлений ARMory в Telegram | [ARMory →](ARMory.md) |
| `scripts/ssk-scraper/` | Управление задачами парсера `flat-parser` | [SSK-Scraper →](ssk-scraper.md) |
| `lib/` | Общие библиотеки: логирование, валидация, Telegram | [Libraries →](libraries.md) |
| `archive/cartman/` | **Архив.** Старые скрипты проекта Cartman | [Cartman (archive) →](cartman.md) |

---

## Архитектура в двух словах

- **Единый `.env` в `scripts/scripts/.env`** — переменные для активных модулей (`FLAT_PARSER_DIR`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`, `SCHEDULER_TASKS`).
- **`lib/common.sh`** — загрузка env, проверка переменных, логирование, обработка ошибок.
- **`lib/telegram.sh`** — отправка сообщений в Telegram (с retry и backoff).
- **Скрипты сами подключают библиотеки** и загружают нужный `.env`.

Подробнее — в разделе [Архитектура](architecture.md).

---

## Быстрый старт

### 1. Основной конфиг

Создать `scripts/scripts/.env` (шаблон — `scripts/scripts/.env.example`):

```dotenv
FLAT_PARSER_DIR=/path/to/flat-parser
TELEGRAM_BOT_TOKEN="<token>"
TELEGRAM_CHAT_ID="<chat_id>"
SCHEDULER_TASKS='{...}'
```

### 2. Права на выполнение

```bash
chmod +x scripts/ARMory/*.sh scripts/ssk-scraper/*.sh
```

### 3. Запуск

```bash
# Задача парсера
./scripts/ssk-scraper/run_erz_nashdom.sh

# Отправка сообщения от ARMory
./scripts/ARMory/send_armory_telegram.sh /path/to/message.txt
```

---

## 📢 Telegram

**URL Format:** `telegram://token@telegram?chats=channel-1[,chat-id-1,...]`

Эмодзи, используемые в сообщениях: ℹ️ ⚠️ ❌ ✅ ✈️ 🤬 🔔 🚀

### Полезные команды

**Узнать ID канала:**
```
https://api.telegram.org/bot{TOKEN}/getUpdates
```

**Отправка тестового сообщения:**
```bash
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
  -d "chat_id=$TELEGRAM_CHAT_ID&text=Тест"
```

---

## ⏰ Запуск по времени

**`at`** — разовый запуск:
```bash
echo "/path/to/scripts/ssk-scraper/run_erz_nashdom.sh >> /path/to/log.log 2>&1" | at 18:26
```

**`crontab`** — регулярный запуск:
```bash
# Каждый день в 2:30
30 2 * * * /path/to/scripts/ssk-scraper/run_erz_nashdom.sh >> /path/to/log.log 2>&1
```
