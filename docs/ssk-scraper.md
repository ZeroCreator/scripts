# SSK-Scraper 🕸

Модуль для управления задачами парсера `flat-parser` (скрейпинг недвижимости).

Все скрипты делегируют выполнение `run_remote.sh`, который подключается к проекту `flat-parser` и выполняет команды через `docker compose`.

---

## Переменные окружения

Файл `ssk-scraper/.env`:

```dotenv
# Путь до проекта flat-parser
FLAT_PARSER_DIR=~/flat-parser

# Scheduler tasks (JSON)
SCHEDULER_TASKS='{
  "erz-nashdom":       {"name": "ERZ + Наш.Дом.РФ Литеры + ПД",   "script": "run_erz_nashdom.sh"},
  "trendagent":        {"name": "TrendAgent (ЖК + квартиры + отделка)", "script": "run_trendagent.sh"},
  "trendagent-flats":  {"name": "TrendAgent (только квартиры)",      "script": "run_trendagent_flats.sh"},
  "installments":      {"name": "Рассрочки из Google Sheets",          "script": "run_installments.sh"},
  "prodoma":           {"name": "Отчёты Продома.Дом.РФ",               "script": "run_prodoma.sh"},
  "daily-report":      {"name": "Ежедневный отчёт в Telegram",         "script": "run_daily_report.sh"},
  "docker-up":         {"name": "🟢 Docker up (trendagent-worker)",   "script": "docker_up.sh"},
  "docker-down":       {"name": "🔴 Docker down (trendagent-worker)", "script": "docker_down.sh"}
}'
```

---

## Скрипты

### `run_remote.sh`

Базовый скрипт удалённого выполнения. Загружает `ssk-scraper/.env`, переходит в `FLAT_PARSER_DIR` и выполняет переданную команду.

```bash
./run_remote.sh '<docker или celery команда>'
```

Остальные скрипты — это обёртки над `run_remote.sh`:

| Скрипт | Описание | Выполняемая команда |
|---|---|---|
| `run_erz_nashdom.sh` | ERZ + Наш.Дом.РФ Литеры + ПД | `celery call parser.parse-all` |
| `run_trendagent.sh` | TrendAgent (ЖК + квартиры + отделка) | `celery call parser.parse-trendagent` |
| `run_trendagent_flats.sh` | TrendAgent (только квартиры) | `celery call parser.parse-trendagent-only-flats` |
| `run_installments.sh` | Рассрочки из Google Sheets | `celery call parser.parse-installments` |
| `run_prodoma.sh` | Отчёты Продома.Дом.РФ | `celery call parser.parse-prodoma` |
| `run_daily_report.sh` | Ежедневный отчёт в Telegram | `celery call parser.send-daily-report` |
| `docker_up.sh` | Запуск контейнеров trendagent | `docker compose up -d ...` |
| `docker_down.sh` | Остановка контейнеров trendagent | `docker rm -f ...` |

---

## Примеры `crontab`

```bash
# ERZ + Наш.Дом.РФ — каждый день в 2:00
0 2 * * * /path/to/scripts/ssk-scraper/run_erz_nashdom.sh >> /path/to/logs/erz_nashdom.log 2>&1

# TrendAgent (полный) — каждый день в 3:00
0 3 * * * /path/to/scripts/ssk-scraper/run_trendagent.sh >> /path/to/logs/trendagent.log 2>&1

# Ежедневный отчёт — каждый день в 9:00
0 9 * * * /path/to/scripts/ssk-scraper/run_daily_report.sh >> /path/to/logs/daily_report.log 2>&1
```
