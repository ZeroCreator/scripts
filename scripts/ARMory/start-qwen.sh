#!/usr/bin/env bash

set -e

PORT=8082
MODEL="Qwen/Qwen2.5-Coder-14B-Instruct-GGUF:Q4_K_M"

echo "=== Запуск Qwen ==="

# Останавливаем старый сервер
pkill -f "llama-server" 2>/dev/null || true

sleep 2

cd ~/llama.cpp

setsid ./build/bin/llama-server \
    -hf "$MODEL" \
    --host 127.0.0.1 \
    --port $PORT \
    -ngl 25 \
    -c 8192 \
    --flash-attn on \
    > ~/llama-server.log 2>&1 < /dev/null &

PID=$!

echo "PID: $PID"

echo "Ожидание запуска..."

for i in {1..30}; do
    if curl -s http://127.0.0.1:${PORT}/v1/models >/dev/null; then
        echo
        echo "======================================"
        echo "Qwen успешно запущена."
        echo "API: http://127.0.0.1:${PORT}/v1"
        echo "Лог: ~/llama-server.log"
        echo "======================================"
        exit 0
    fi

    printf "."
    sleep 1
done

echo
echo "Сервер не запустился."
echo
tail -50 ~/llama-server.log
exit 1