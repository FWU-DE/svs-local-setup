#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew is not installed." >&2
  echo "       Install via: https://brew.sh" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: Node.js is not installed." >&2
  echo "       Install via: brew install node" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SERVER_DIR="$ROOT_DIR/repos/schulcloud-server"

if [[ ! -d "$SERVER_DIR/.git" ]]; then
  echo "ERROR: $SERVER_DIR is missing or not a git repository" >&2
  exit 1
fi

CONTAINER_NAME="mongodb"
DB_URL="mongodb://127.0.0.1:27017/schulcloud"

if ! docker ps --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "ERROR: MongoDB container '$CONTAINER_NAME' is not running." >&2
  echo "       Run scripts/mac/03-start-mongodb.sh first." >&2
  exit 1
fi

COLLECTION_COUNT=$(docker exec "$CONTAINER_NAME" mongosh "$DB_URL" --quiet --eval "db.getCollectionNames().length" 2>/dev/null || echo "0")

if [[ "$COLLECTION_COUNT" -gt 0 ]]; then
  echo "INFO: MongoDB already seeded ($COLLECTION_COUNT collections found), skipping." >&2
  exit 0
fi

echo "INFO: Seeding MongoDB in schulcloud-server..." >&2
(cd "$SERVER_DIR" && npm run setup:db:seed)
