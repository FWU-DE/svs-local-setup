#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helper/local-config.sh"

for target in "$SERVER_DIR" "$CLIENT_DIR" "$NUXT_CLIENT_DIR"; do
  name="$(basename "$target")"

  if [[ ! -d "$target/.git" ]]; then
    echo "ERROR: $target is missing or not a git repository" >&2
    exit 1
  fi

  if [[ ! -f "$target/package.json" ]]; then
    echo "INFO: Skipping $name (no package.json)" >&2
    continue
  fi

  echo "INFO: Installing Node.js dependencies for $name..." >&2
  (cd "$target" && npm ci --no-audit --no-fund)
done
