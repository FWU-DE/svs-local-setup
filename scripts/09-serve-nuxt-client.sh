#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLIENT_DIR="$ROOT_DIR/repos/nuxt-client"

if [[ ! -d "$CLIENT_DIR/.git" ]]; then
  echo "ERROR: $CLIENT_DIR is missing or not a git repository" >&2
  exit 1
fi

echo "INFO: Starting nuxt-client..." >&2
(cd "$CLIENT_DIR" && npm run serve)
