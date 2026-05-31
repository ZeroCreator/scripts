#!/bin/bash

#--------------------------------------------------------------------
# Common library for project scripts
# Общая библиотека для скриптов проекта
#--------------------------------------------------------------------

# Определяем корень проекта относительно расположения этого файла
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Загрузка переменных из .env файла
# Usage: load_env /path/to/.env
load_env() {
    local env_file="$1"
    if [ -f "$env_file" ]; then
        set -a
        # shellcheck source=/dev/null
        source "$env_file"
        set +a
    else
        echo "Файл конфигурации $env_file не найден." >&2
        exit 1
    fi
}

# Проверка обязательных переменных
# Usage: require_vars VAR1 VAR2 ...
require_vars() {
    for var in "$@"; do
        if [ -z "${!var:-}" ]; then
            echo "Переменная $var не задана" >&2
            exit 1
        fi
    done
}

# Логирование с временной меткой
# Usage: log_with_timestamp "message"
log_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Инициализация лог-файла с перенаправлением stdout/stderr
# Usage: init_log /path/to/logfile
init_log() {
    local log_file="$1"
    mkdir -p "$(dirname "$log_file")"
    exec 3>&1 4>&2
    exec > >(tee -a "$log_file") 2>&1
}

# Обработчик ошибок (используется с trap)
# Usage: trap 'handle_error ${LINENO} "${BASH_COMMAND}"' ERR
handle_error() {
    local exit_code=$?
    local line_number=$1
    local command=$2
    log_with_timestamp "Ошибка в строке ${line_number}: ${command} (код ${exit_code})" >&2
    exit ${exit_code}
}
