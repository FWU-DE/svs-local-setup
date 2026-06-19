#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_DIR="$ROOT_DIR/repos/schulcloud-server"

CONTAINER_NAME="mongodb"

if [[ ! -d "$SERVER_DIR/.git" ]]; then
  echo "ERROR: $SERVER_DIR is missing or not a git repository" >&2
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "ERROR: MongoDB container '$CONTAINER_NAME' is not running." >&2
  echo "       Run scripts/03-start-mongodb.sh first." >&2
  exit 1
fi

echo "INFO: Seeding MongoDB in schulcloud-server..." >&2
(cd "$SERVER_DIR" && npm run setup:db:seed)
