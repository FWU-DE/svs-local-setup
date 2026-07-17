#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helper/local-config.sh"

if [[ ! -d "$NUXT_CLIENT_DIR/.git" ]]; then
  echo "ERROR: $NUXT_CLIENT_DIR is missing or not a git repository" >&2
  exit 1
fi

echo "INFO: Starting nuxt-client..." >&2
(cd "$NUXT_CLIENT_DIR" && npm run serve)
