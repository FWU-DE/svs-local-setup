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
CLIENT_DIR="$ROOT_DIR/repos/schulcloud-client"

if [[ ! -d "$CLIENT_DIR/.git" ]]; then
  echo "ERROR: $CLIENT_DIR is missing or not a git repository" >&2
  exit 1
fi

echo "INFO: Building schulcloud-client..." >&2
(cd "$CLIENT_DIR" && npm run build)

echo "INFO: Watching schulcloud-client..." >&2
(cd "$CLIENT_DIR" && npm run watch)
