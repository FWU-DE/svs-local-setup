#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew is not installed." >&2
  echo "       Install via: https://brew.sh" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is not installed." >&2
  echo "       Install via: brew install git" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPOS_DIR="$ROOT_DIR/repos"

mkdir -p "$REPOS_DIR"

repos=(
  "schulcloud-server https://github.com/hpi-schul-cloud/schulcloud-server"
  "nuxt-client https://github.com/hpi-schul-cloud/nuxt-client"
  "schulcloud-client https://github.com/hpi-schul-cloud/schulcloud-client"
)

for entry in "${repos[@]}"; do
  name="${entry%% *}"
  url="${entry#* }"
  target="$REPOS_DIR/$name"

  if [[ -d "$target/.git" ]]; then
    echo "INFO: Updating $name..." >&2
    git -C "$target" pull --ff-only
  elif [[ -e "$target" ]]; then
    echo "ERROR: $target exists but is not a git repository" >&2
    exit 1
  else
    echo "INFO: Cloning $name..." >&2
    git clone "$url" "$target"
  fi
done
