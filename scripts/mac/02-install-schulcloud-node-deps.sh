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
REPOS_DIR="$ROOT_DIR/repos"

for name in $(ls "$REPOS_DIR"); do
  target="$REPOS_DIR/$name"

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
