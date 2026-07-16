# Архитектура проекта

Проект `scripts` — монорепозиторий вспомогательных DevOps-скриптов.

---

## Структура

```
scripts/
├── config.env              # [архив] Общие переменные для старых скриптов Cartman
├── mkdocs.yml              # Конфигурация документации
├── lib/                    # Общие библиотеки
│   ├── common.sh           # Загрузка env, валидация, логирование, ошибки
│   └── telegram.sh         # Отправка сообщений в Telegram
├── scripts/                # Активные скрипты
│   ├── scripts/.env        # Единый env для активных модулей
│   ├── ARMory/             # Модуль: уведомления ARMory
│   │   └── *.sh
│   └── ssk-scraper/        # Модуль: парсер flat-parser
│       └── *.sh
└── archive/                # Архивные скрипты
    └── cartman/            # Старые скрипты Cartman
```

---

## Принципы

### 1. Единый `.env` для активных модулей

Файл `scripts/scripts/.env` содержит переменные для всех активных скриптов:

```dotenv
# Путь до flat-parser
FLAT_PARSER_DIR=/path/to/flat-parser

# Telegram
TELEGRAM_BOT_TOKEN="<token>"
TELEGRAM_CHAT_ID="<chat_id>"

# Scheduler tasks (JSON)
SCHEDULER_TASKS='{...}'
```

> Архивные скрипты `archive/cartman/` по-прежнему используют корневой `config.env` и локальный `archive/cartman/.env`.

### 2. Общие библиотеки `lib/`

Дублирующаяся логика вынесена в библиотеки:

| Библиотека | Назначение |
|---|---|
| `lib/common.sh` | `load_env`, `require_vars`, `log_with_timestamp`, `init_log`, `handle_error` |
| `lib/telegram.sh` | `send_telegram_message`, `send_telegram_message_retry` |

### 3. Подключение в скриптах

Каждый скрипт подключает библиотеки и загружает env самостоятельно:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/../lib/common.sh"
load_env "$PROJECT_ROOT/.env"
source "$PROJECT_ROOT/../lib/telegram.sh"
```

> Скрипты не принимают путь к конфигу через аргументы командной строки.

---

## Добавление нового модуля

1. Создать папку `scripts/new-module/`
2. Добавить переменные модуля в `scripts/scripts/.env`
3. Создать скрипты, используя шаблон подключения `lib/common.sh` и `lib/telegram.sh`
4. Добавить документацию в `docs/`
5. Добавить модуль в `nav:` `mkdocs.yml`
