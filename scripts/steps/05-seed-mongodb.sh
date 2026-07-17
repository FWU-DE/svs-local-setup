#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helper/local-config.sh"

MONGODB_CONTAINER_NAME="mongodb"
if [[ ! -d "$SERVER_DIR/.git" ]]; then
  echo "ERROR: $SERVER_DIR is missing or not a git repository" >&2
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -Fx "$MONGODB_CONTAINER_NAME" >/dev/null 2>&1; then
  echo "ERROR: MongoDB container '$MONGODB_CONTAINER_NAME' is not running." >&2
  echo "       Run scripts/steps/03-start-mongodb.sh first." >&2
  exit 1
fi

echo "INFO: Seeding MongoDB in schulcloud-server..." >&2
(cd "$SERVER_DIR" && npm run setup:db:seed)
