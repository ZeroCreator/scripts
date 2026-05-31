#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/lib/common.sh"
load_env "$PROJECT_ROOT/config.env"
load_env "$SCRIPT_DIR/.env"

REMOTE_DIR="${FLAT_PARSER_DIR:-/home/devel/flat-parser}"
REMOTE_CMD="${1:-}"

if [ -z "$REMOTE_CMD" ]; then
    echo "Usage: $0 '<command>'" >&2
    exit 1
fi

cd "$REMOTE_DIR" && eval "$REMOTE_CMD"
