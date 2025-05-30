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

Вначале необходимо создать в папке проекта файл **config.env** с переменными окружения (*при первой установке приложения*):

```dotenv
# Переменные проекта
WORKDIR=/path/to/project
LOGDIR=/path/to/logs
PROJECT_NAME=project_name

# TELEGRAM
TELEGRAM_TOKEN="<telegram-token>"
TELEGRAM_CHAT_ID="<telegram_chat_id>"

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

---
## 📝 Документация

Документация проекта доступна в формате `mkdocs` на **GitHub**:

➡️ https://zerocreator.github.io/scripts/.

---

### Локальное развертывание документации

Для запуска интерфейса документации **локально** необходимо выполнить следующие команды:

1️⃣.  Создать и активировать виртуальное окружение (*при первой установке приложения*):

```bash
$ python3 -m venv scripts_venv
$ source scripts_venv/bin/activate
```

2️⃣.  Затем установить пакеты mkdocs (*при первой установке приложения*):

```bash
$ cd scripts
$ pip3 install mkdocs
$ pip install mkdocs-material
```

3️⃣.  Запустить 📝 mkdocs:

```bash
$ mkdocs serve
```

Документация будет доступна **локально** по адресу http://localhost:8000

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
$ echo "/path/to/scripts/script_name.sh /path/to/scripts/config.env >> /path/to/scripts/script_log.log 2>&1" | at <h>:<m> <YY>-<m>-<d>
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
