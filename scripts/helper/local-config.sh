#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="$ROOT_DIR/.env.local"

if [[ -f "$ENV_FILE" ]]; then
  if [[ -n ${SCHULCLOUD_REPOS_DIR+x} ]]; then
    _SCHULCLOUD_REPOS_DIR_FROM_ENV="$SCHULCLOUD_REPOS_DIR"
  fi

  # shellcheck disable=SC1090
  source "$ENV_FILE"

  if [[ -n ${_SCHULCLOUD_REPOS_DIR_FROM_ENV+x} ]]; then
    SCHULCLOUD_REPOS_DIR="$_SCHULCLOUD_REPOS_DIR_FROM_ENV"
  fi

  unset _SCHULCLOUD_REPOS_DIR_FROM_ENV
fi

REPOS_DIR="${SCHULCLOUD_REPOS_DIR:-$ROOT_DIR/repos}"
SERVER_DIR="$REPOS_DIR/schulcloud-server"
CLIENT_DIR="$REPOS_DIR/schulcloud-client"
NUXT_CLIENT_DIR="$REPOS_DIR/nuxt-client"

export ROOT_DIR REPOS_DIR SERVER_DIR CLIENT_DIR NUXT_CLIENT_DIR
