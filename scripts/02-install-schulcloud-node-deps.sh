#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_DIR="$ROOT_DIR/repos"

repos=(
  "schulcloud-server"
  "nuxt-client"
  "schulcloud-client"
)

for name in "${repos[@]}"; do
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
