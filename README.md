# scripts

## Документация
Документация проекта доступна в формате `mkdocs`.
Для запуска интерфейса документации необходимо выполнить следующие команды:

Создать и активировать виртуальное окружение:

```bash
$ python3 -m venv scripts_venv
$ source scripts_venv/bin/activate
```

Затем установить пакеты mkdocs:

```bash
$ pip3 install mkdocs
$ pip install mkdocs-material
```

Запустить mkdocs:

```bash
$ mkdocs serve
```

Документация будет доступна по адресу http://localhost:8000
