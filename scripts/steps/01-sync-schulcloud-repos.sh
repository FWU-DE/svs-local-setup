#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helper/local-config.sh"

mkdir -p "$REPOS_DIR"

repos=(
  "schulcloud-server https://github.com/hpi-schul-cloud/schulcloud-server"
  "schulcloud-client https://github.com/hpi-schul-cloud/schulcloud-client"
  "nuxt-client https://github.com/hpi-schul-cloud/nuxt-client"
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
