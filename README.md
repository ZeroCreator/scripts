# scripts

```
SSSSSSS    CCCCCC   RRRRRR    IIIII   PPPPPP   TTTTTTT  SSSSSSS
S         C         R     R     I     P     P     T     S
 SSSSS    C         RRRRRR      I     PPPPPP      T      SSSSS
      S   C         R   R       I     P           T           S
SSSSSSS    CCCCCC   R    R    IIIII   P           T     SSSSSSS
``` 

🚀 **Scripts** - пакет скриптов и документации для DevOps-сопровождения проектов.


---
## 🛠 Подготовка к запуску и запуск

Проект разделён на модули (папки). Общие переменные (например, Telegram) хранятся в корневом файле **`config.env`**, а переменные, специфичные для каждого модуля — в локальных **`.env`** внутри соответствующих папок.

### 1. Общий конфиг `config.env` (в корне проекта)

Содержит только общие переменные:

```dotenv
# TELEGRAM
TELEGRAM_TOKEN="<telegram-token>"
TELEGRAM_CHAT_ID="<telegram_chat_id>"
```

### 2. Локальные `.env` в папках проектов

Пример для папки `cartman/.env`:

```dotenv
# Переменные проекта
WORKDIR=/path/to/project
LOGDIR=/path/to/logs
PROJECT_NAME=project_name

# Для скрипта redeploy
DOCKER_REGISTRY="<docker-registry_url>"

# Для остальных скриптов
LOG_FILE="/path/to/log.log"
CONTAINER_NAME="<container_name>"
TIMESTAMP_HOST_FILE="/path/to/project_timestamp_file.txt"
TIME_DELTA=<time_delta>

# Для proxy-scheduler
DATE_FILE="/path/to/initial_date.txt"
MESSAGE="<message>"
PAST_DATE="<past_date>"
```

Пример для папки `ssk-scraper/.env`:

```dotenv
# Путь до проекта flat-parser
FLAT_PARSER_DIR=/path/to/project

# Scheduler tasks (JSON)
SCHEDULER_TASKS='{...}'
```

---
## 📝 Документация

📖 Документация проекта доступна в формате `mkdocs` на **GitHub**:

➡️ https://zerocreator.github.io/scripts/.

---

### Локальное развертывание документации

Документация построена на [MkDocs](https://www.mkdocs.org/) с темой [Material](https://squidfunk.github.io/mkdocs-material/).

Для запуска интерфейса документации **локально** необходимо выполнить следующие команды:

1️⃣.  Создать и активировать виртуальное окружение через `uv` (*при первой установке приложения*):

```bash
$ uv venv scripts_venv --clear
$ source scripts_venv/bin/activate
```

2️⃣.  Затем установить пакеты mkdocs (*при первой установке приложения*):

```bash
$ uv pip install mkdocs mkdocs-material
```

3️⃣.  Запустить 📝 mkdocs:

```bash
$ uv run mkdocs serve --dev-addr 127.0.0.1:<PORT>
```

Документация будет доступна **локально** по адресу `http://localhost:<PORT>`

---
### Сборка документации для **GitHub**:

Выполнить команду:

```bash
$ mkdocs gh-deploy
```

Эта команда выполнит следующие действия:

  - Соберет документацию.
  - Создаст ветку gh-pages в репозитории, если она еще не существует.
  - Загрузит сгенерированные файлы в ветку gh-pages.

После завершения развертывания и настройки **GitHub Pages**, 📝 документация будет доступна по адресу:

➡️ https://yourusername.github.io/my_project/

Если вносятся изменения в документацию, необходимо повторить команду `mkdocs gh-deploy`, чтобы обновить 
содержимое на **GitHub Pages**.

---
## ⏰ Запуск скриптов по времени

Для запуска скриптов по времени ипользуется **crontab** и утилита **at**.

Примеры запуска скриптов с помощью утилиты **at**:
```bash
$ echo "/path/to/scripts/cartman/redeploy.sh >> /path/to/scripts/cartman_log.log 2>&1" | at <h>:<m> <YY>-<m>-<d>
```

Для просмотра запланированных задач можно использовать команду `atq`:
```bash
$ atq
```

Чтобы удалить запланированную задачу, используйте команду `atrm` с указанием номера задачи, который можно получить с помощью `atq`:
```bash
$ atrm 1
```
   
Примеры запуска скриптов с помощью **crontab**:

Войти в crontab:
```bash
$ crontab - e
```

Запуск скрипта:
```bash
30 2 * * * /path/to/your/script.sh || /path/to/send_telegram_message.sh "Cron job failed!"
```
