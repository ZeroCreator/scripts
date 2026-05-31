# Архитектура проекта

Проект `scripts` — монорепозиторий вспомогательных DevOps-скриптов, разделённый на модули.

---

## Структура

```
scripts/
├── config.env              # Общие переменные (Telegram)
├── mkdocs.yml              # Конфигурация документации
├── lib/                    # Общие библиотеки
│   ├── common.sh           # Загрузка env, валидация, логирование, ошибки
│   └── telegram.sh         # Отправка сообщений в Telegram
├── cartman/                # Модуль: проект Cartman
│   ├── .env                # Локальные переменные Cartman
│   └── *.sh                # Скрипты Cartman
└── ssk-scraper/            # Модуль: парсер flat-parser
    ├── .env                # Локальные переменные SSK-Scraper
    ├── .env.example        # Шаблон .env
    └── *.sh                # Скрипты SSK-Scraper
```

---

## Принципы

### 1. Общий конфиг в корне
Файл `config.env` содержит **только** переменные, общие для всех модулей:

```dotenv
# TELEGRAM
TELEGRAM_TOKEN="<token>"
TELEGRAM_CHAT_ID="<chat_id>"
```

### 2. Локальный `.env` в каждом модуле
Каждая папка модуля имеет свой `.env` со специфичными переменными:

- `cartman/.env` — `WORKDIR`, `LOGDIR`, `PROJECT_NAME`, `DOCKER_REGISTRY`, `CONTAINER_NAME`, `LOG_FILE`, `TIME_DELTA` и т.д.
- `ssk-scraper/.env` — `FLAT_PARSER_DIR`, `SCHEDULER_TASKS`

### 3. Общие библиотеки `lib/`
Дублирующаяся логика вынесена в библиотеки:

| Библиотека | Назначение |
|---|---|
| `lib/common.sh` | `load_env`, `require_vars`, `log_with_timestamp`, `init_log`, `handle_error` |
| `lib/telegram.sh` | `send_telegram_message`, `send_telegram_message_retry` |

### 4. Подключение в скриптах
Каждый скрипт подключает библиотеки и загружает env самостоятельно:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/lib/common.sh"
load_env "$PROJECT_ROOT/config.env"   # общие переменные
load_env "$SCRIPT_DIR/.env"           # локальные переменные
source "$PROJECT_ROOT/lib/telegram.sh"
```

> Скрипты больше не принимают путь к конфигу через аргумент командной строки.

---

## Схема загрузки переменных

```
┌─────────────────┐
│   config.env    │  TELEGRAM_TOKEN, TELEGRAM_CHAT_ID
│    (корень)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│   lib/common.sh │────▶│   cartman/.env  │  WORKDIR, CONTAINER_NAME, ...
│  load_env()     │     │                 │
└─────────────────┘     └─────────────────┘
         │
         └──────────────▶┌─────────────────┐
                         │ ssk-scraper/.env │  FLAT_PARSER_DIR, SCHEDULER_TASKS
                         │                 │
                         └─────────────────┘
```

---

## Добавление нового модуля

1. Создать папку `new-module/`
2. Создать `new-module/.env` с переменными модуля
3. Создать скрипты, используя шаблон подключения `lib/common.sh` и `lib/telegram.sh`
4. Добавить документацию в `docs/`
5. Добавить модуль в `nav:` `mkdocs.yml`
