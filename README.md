# scripts

```
SSSSSSS    CCCCCC   RRRRRR    IIIII   PPPPPP   TTTTTTT  SSSSSSS
S         C         R     R     I     P     P     T     S
 SSSSS    C         RRRRRR      I     PPPPPP      T      SSSSS
      S   C         R   R       I     P           T           S
SSSSSSS    CCCCCC   R    R    IIIII   P           T     SSSSSSS
``` 

🚀 **Scripts** — монорепозиторий вспомогательных скриптов для DevOps-сопровождения проектов.

---
## 🛠 Подготовка к запуску и запуск

Активные скрипты находятся в папке `scripts/`. Переменные окружения для них хранятся в едином файле **`scripts/scripts/.env`**.

> Старые скрипты **Cartman** заархивированы в `archive/cartman/` и не используются в активных задачах. Для них по-прежнему нужны корневой `config.env` и локальный `archive/cartman/.env`.

### 1. Основной конфиг `scripts/scripts/.env`

```dotenv
# Путь до проекта flat-parser (используется run_remote.sh)
FLAT_PARSER_DIR=/path/to/flat-parser

# Telegram (для send_armory_telegram.sh)
TELEGRAM_BOT_TOKEN="<token>"
TELEGRAM_CHAT_ID="<chat_id>"

# Scheduler tasks (JSON)
SCHEDULER_TASKS='{...}'
```

Шаблон — в файле `scripts/scripts/.env.example`.

### 2. Права на выполнение

```bash
chmod +x scripts/ARMory/*.sh scripts/ssk-scraper/*.sh
```

### 3. Прямой запуск

```bash
./scripts/ssk-scraper/run_erz_nashdom.sh
./scripts/ARMory/send_armory_telegram.sh /path/to/message.txt
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

Для запуска скриптов по времени используется **crontab** и утилита **at**.

Примеры запуска скриптов с помощью утилиты **at**:
```bash
$ echo "/path/to/scripts/ssk-scraper/run_erz_nashdom.sh >> /path/to/logs/erz_nashdom.log 2>&1" | at <h>:<m> <YY>-<m>-<d>
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
$ crontab -e
```

Запуск скрипта:
```bash
30 2 * * * /path/to/your/script.sh || /path/to/scripts/ARMory/send_armory_telegram.sh "Cron job failed!"
```
