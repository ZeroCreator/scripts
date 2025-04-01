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
➡️ Все переменные окружения для работы скриптов лежат в `config.env` корневой папки `scripts`.

➡️ Сделать скрипт исполняемым:
```bash
chmod +x <script_name>.sh
```

➡️ **URL Format** для переменной **telegram**:

`telegram://token@telegram?chats=channel-1[,chat-id-1,...]`

➡️ Эмодзи, используемые для сообщений в telegram:

ℹ️ ⚠️ ❌ ✅ ✈️ 🤬 🔔 🚀

---
## Команды для telegram:

1️⃣. Узнать **ID** канала ➡️

https://api.telegram.org/bot{TOKEN}/getUpdates

2️⃣. Отправка сообщений для тестирования:

```bash
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$MESSAGE"
curl -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=Тестовое сообщение"
```

3️⃣. Поиграться с сообщениями в **cron**:

```bash
30 2 * * * /path/to/your/script.sh || /path/to/send_telegram_message.sh "Cron job failed!"
```

4️⃣. Смотреть логи в реальном времени:

```bash
tail -f ~/scripts/<script_name>.log
```

5️⃣. **Shoutrrr** - для просмотра доступных по **TELEGRAM_TOKEN** _telegram-каналов_:
https://containrrr.dev/shoutrrr/v0.8/services/telegram/

```bash
docker run --rm -it containrrr/shoutrrr generate telegram
```

