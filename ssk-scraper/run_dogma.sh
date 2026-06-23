#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load local environment for this scripts project
set -a
# shellcheck source=/dev/null
source "$SCRIPT_DIR/.env"
set +a

cd "${FLAT_PARSER_DIR:-/home/zerocreator/Flat-parser/flat-parser}"
uv run python manage.py parse_dogma
