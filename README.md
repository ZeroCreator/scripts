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
## 📝 Документация

Документация проекта доступна в формате `mkdocs` на **GitHub**:

➡️ https://zerocreator.github.io/scripts/.

---
### Локальное развертывание документации

Для запуска интерфейса документации **локально** необходимо выполнить следующие команды:

1️⃣. Создать и активировать виртуальное окружение:

```bash
$ python3 -m venv scripts_venv
$ source scripts_venv/bin/activate
```

2️⃣. Затем установить пакеты mkdocs:

```bash
$ cd scripts
$ pip3 install mkdocs
$ pip install mkdocs-material
```

3️⃣. Запустить 📝 mkdocs:

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
