#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="mongodb"
MONGODB_URI="mongodb://localhost:27017"

if ! docker ps -a --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "ERROR: MongoDB container '$CONTAINER_NAME' does not exist." >&2
  echo "       Run scripts/steps/03-start-mongodb.sh first." >&2
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "ERROR: MongoDB container '$CONTAINER_NAME' is not running." >&2
  echo "       Run scripts/steps/03-start-mongodb.sh first." >&2
  exit 1
fi

echo "INFO: Connecting to MongoDB container '$CONTAINER_NAME' at $MONGODB_URI..." >&2
exec docker exec -it "$CONTAINER_NAME" mongosh "$MONGODB_URI" "$@"
