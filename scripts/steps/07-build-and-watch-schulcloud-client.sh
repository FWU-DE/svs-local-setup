#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helper/local-config.sh"

if [[ ! -d "$CLIENT_DIR/.git" ]]; then
  echo "ERROR: $CLIENT_DIR is missing or not a git repository" >&2
  exit 1
fi

echo "INFO: Building schulcloud-client..." >&2
(cd "$CLIENT_DIR" && npm run build)

echo "INFO: Watching schulcloud-client..." >&2
(cd "$CLIENT_DIR" && npm run watch)
