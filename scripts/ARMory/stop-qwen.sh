#!/usr/bin/env bash

echo "=== Остановка llama-server ==="

PIDS=$(pgrep -f "llama-server")

if [ -z "$PIDS" ]; then
    echo "Сервер не запущен."
    exit 0
fi

echo "Найдены процессы:"
echo "$PIDS"

kill $PIDS

for i in {1..10}; do
    if ! pgrep -f "llama-server" >/dev/null; then
        echo
        echo "Сервер успешно остановлен."
        exit 0
    fi
    sleep 1
done

echo "Процесс не завершился, принудительное завершение..."

pkill -9 -f "llama-server"

echo "Готово."