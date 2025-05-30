# ВВЕДЕНИЕ

```
SSSSSSS    CCCCCC   RRRRRR    IIIII   PPPPPP   TTTTTTT  SSSSSSS
S         C         R     R     I     P     P     T     S
 SSSSS    C         RRRRRR      I     PPPPPP      T      SSSSS
      S   C         R   R       I     P           T           S
SSSSSSS    CCCCCC   R    R    IIIII   P           T     SSSSSSS
``` 

🚀 **Scripts** - пакет скриптов и документации для DevOps-сопровождения проектов.

---
⚠️ Все переменные окружения для работы скриптов лежат в `config.env` корневой папки `scripts`.

---
🪛 Сделать скрипт исполняемым: ➡️
```bash
chmod +x <script_name>.sh
```

---
🔌 **URL Format** для переменной **telegram**: ➡️

`telegram://token@telegram?chats=channel-1[,chat-id-1,...]`

---
✈️ Эмодзи, используемые для сообщений в telegram: ➡️

ℹ️ ⚠️ ❌ ✅ ✈️ 🤬 🔔 🚀

---
## 📢 Команды для telegram:

1️⃣.  🔬 Узнать **ID** канала: ➡️

https://api.telegram.org/bot{TOKEN}/getUpdates

2️⃣.  🏌️‍♀️ Отправка сообщений для тестирования: ➡️
```bash
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$MESSAGE"
curl -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=Тестовое сообщение"
```

3️⃣.  👀 Смотреть логи в реальном времени: ➡️
```bash
$ tail -f ~/scripts/<script_name>.log
```

5️⃣.  👣 **Shoutrrr** - для просмотра доступных по **TELEGRAM_TOKEN** _telegram-каналов_: ➡️
https://containrrr.dev/shoutrrr/v0.8/services/telegram/

```bash
$ docker run --rm -it containrrr/shoutrrr generate telegram
```

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
## ⏰ Запуск скриптов по времени

Для запуска скриптов по времени ипользуется **crontab** и утилита Linux **at**.

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
