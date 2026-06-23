# SSK-Scraper 🕸

Модуль для управления задачами парсера `flat-parser` (скрейпинг недвижимости).

Большинство скриптов делегируют выполнение `run_remote.sh`, который переходит в директорию `flat-parser` и выполняет переданную команду локально.

---

## Переменные окружения

Файл `ssk-scraper/.env`:

```dotenv
# Путь до проекта flat-parser
FLAT_PARSER_DIR=~/flat-parser

# Scheduler tasks (JSON)
SCHEDULER_TASKS='{
  "erz-nashdom":       {"name": "ERZ + Наш.Дом.РФ Литеры + ПД",              "script": "run_erz_nashdom.sh"},
  "trendagent":        {"name": "TrendAgent (ЖК + квартиры + отделка)",      "script": "run_trendagent.sh"},
  "trendagent-flats":  {"name": "TrendAgent (только квартиры)",             "script": "run_trendagent_flats.sh"},
  "installments":      {"name": "Рассрочки из Google Sheets",                "script": "run_installments.sh"},
  "prodoma":           {"name": "Отчёты Продома.Дом.РФ",                     "script": "run_prodoma.sh"},
  "daily-report":      {"name": "Ежедневный отчёт в Telegram",               "script": "run_daily_report.sh"},
  "dogma":             {"name": "Dogma — парсинг и рассылка XLSX",           "script": "run_dogma.sh"},
  "docker-up":         {"name": "🟢 Docker up (trendagent-worker)",         "script": "docker_up.sh"},
  "docker-down":       {"name": "🔴 Docker down (trendagent-worker)",       "script": "docker_down.sh"}
}'
```

---

## Скрипты

### `run_remote.sh`

Базовый скрипт запуска команд внутри проекта `flat-parser`. Загружает `ssk-scraper/.env`, переходит в `FLAT_PARSER_DIR` и выполняет переданную команду.

```bash
./run_remote.sh '<docker или celery команда>'
```

### `run_dogma.sh`

Запускает парсинг и рассылку Dogma напрямую, без использования `run_remote.sh`.

```bash
./run_dogma.sh
```

Выполняемая команда:

```bash
uv run python manage.py parse_dogma
```

### Остальные скрипты

Остальные скрипты — это обёртки над `run_remote.sh`:

| Скрипт | Описание | Выполняемая команда |
|---|---|---|
| `run_erz_nashdom.sh` | ERZ + Наш.Дом.РФ Литеры + ПД | `docker compose exec -i beat uv run celery -A conf.celery_app call parser.parse-all --queue flat-parser` |
| `run_trendagent.sh` | TrendAgent (ЖК + квартиры + отделка) | `docker compose exec -i beat uv run celery -A conf.celery_app call parser.parse-trendagent --queue flat-parser-trendagent` |
| `run_trendagent_flats.sh` | TrendAgent (только квартиры) | `docker compose exec -i beat uv run celery -A conf.celery_app call parser.parse-trendagent-only-flats --queue flat-parser-trendagent` |
| `run_installments.sh` | Рассрочки из Google Sheets | `docker compose exec -i beat uv run celery -A conf.celery_app call parser.parse-installments --queue flat-parser` |
| `run_prodoma.sh` | Отчёты Продома.Дом.РФ | `docker compose exec -i beat uv run celery -A conf.celery_app call parser.parse-prodoma --queue flat-parser` |
| `run_daily_report.sh` | Ежедневный отчёт в Telegram | `docker compose exec -i beat uv run celery -A conf.celery_app call parser.send-daily-report --queue flat-parser` |
| `docker_up.sh` | Запуск контейнеров trendagent | `docker compose up -d trendagent-worker watch-trendagent-token-updates` |
| `docker_down.sh` | Остановка контейнеров trendagent | `docker rm -f flat-parser-trendagent-worker-1 flat-parser-watch-trendagent-token-updates-1` |

---

## Примеры `crontab`

```bash
# ERZ + Наш.Дом.РФ — каждый день в 2:00
0 2 * * * /path/to/scripts/ssk-scraper/run_erz_nashdom.sh >> /path/to/logs/erz_nashdom.log 2>&1

# TrendAgent (полный) — каждый день в 3:00
0 3 * * * /path/to/scripts/ssk-scraper/run_trendagent.sh >> /path/to/logs/trendagent.log 2>&1

# Dogma — каждый день в 4:00
0 4 * * * /path/to/scripts/ssk-scraper/run_dogma.sh >> /path/to/logs/dogma.log 2>&1

# Ежедневный отчёт — каждый день в 9:00
0 9 * * * /path/to/scripts/ssk-scraper/run_daily_report.sh >> /path/to/logs/daily_report.log 2>&1
```
