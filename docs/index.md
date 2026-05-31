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
| `cartman/` | Скрипты деплоя, мониторинга и обслуживания проекта **Cartman** | [Cartman →](cartman.md) |
| `ssk-scraper/` | Управление задачами парсера `flat-parser` | [SSK-Scraper →](ssk-scraper.md) |
| `lib/` | Общие библиотеки: логирование, валидация, Telegram | [Libraries →](libraries.md) |

---

## Архитектура в двух словах

- **Корневой `config.env`** — только общие переменные (`TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`).
- **Локальный `.env` в каждой папке** — переменные конкретного модуля.
- **`lib/common.sh`** — загрузка env, проверка переменных, логирование, обработка ошибок.
- **`lib/telegram.sh`** — отправка сообщений в Telegram (с retry и backoff).
- **Скрипты не принимают аргументов** — сами подключают библиотеки и загружают env.

Подробнее — в разделе [Архитектура](architecture.md).

---

## Быстрый старт

### 1. Общий конфиг

Создать `config.env` в корне:

```dotenv
TELEGRAM_TOKEN="<telegram-token>"
TELEGRAM_CHAT_ID="<telegram_chat_id>"
```

### 2. Локальные `.env`

- `cartman/.env` — переменные Cartman ([шаблон](cartman.md))
- `ssk-scraper/.env` — переменные SSK-Scraper ([шаблон](ssk-scraper.md))

### 3. Права на выполнение

```bash
chmod +x cartman/*.sh ssk-scraper/*.sh
```

### 4. Запуск

```bash
# Прямой запуск (аргументы не нужны)
./cartman/redeploy.sh
./ssk-scraper/run_erz_nashdom.sh
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
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
  -d "chat_id=$TELEGRAM_CHAT_ID&text=Тест"
```

---

## ⏰ Запуск по времени

**`at`** — разовый запуск:
```bash
echo "/path/to/scripts/cartman/redeploy.sh >> /path/to/log.log 2>&1" | at 18:26
```

**`crontab`** — регулярный запуск:
```bash
# Каждый день в 2:30
30 2 * * * /path/to/scripts/cartman/redeploy.sh >> /path/to/log.log 2>&1
```
