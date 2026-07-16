#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Загружаем единый .env для активных скриптов
set -a
# shellcheck source=/dev/null
source "$PROJECT_ROOT/.env"
set +a

REMOTE_DIR="${FLAT_PARSER_DIR:-/home/devel/flat-parser}"
REMOTE_CMD="${1:-}"
SSH_KEY="${FLAT_PARSER_SSH_KEY:-$HOME/ARMory/deploy/id_ed25519}"

if [ -z "$REMOTE_CMD" ]; then
    echo "Usage: $0 '<command>'" >&2
    exit 1
fi

if [ -n "${FLAT_PARSER_SSH_HOST:-}" ]; then
    ssh -i "$SSH_KEY" -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
        "$FLAT_PARSER_SSH_HOST" "cd $REMOTE_DIR && $REMOTE_CMD"
else
    cd "$REMOTE_DIR" && eval "$REMOTE_CMD"
fi
