#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "INFO: Installing Homebrew..." >&2
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "INFO: Homebrew already installed ($(brew --version | head -1))" >&2
fi

if ! command -v git >/dev/null 2>&1; then
  echo "INFO: Installing git via Homebrew..." >&2
  brew install git
else
  echo "INFO: git already installed ($(git --version))" >&2
fi

if ! command -v node >/dev/null 2>&1; then
  echo "INFO: Installing node via Homebrew..." >&2
  brew install node
else
  echo "INFO: node already installed ($(node --version))" >&2
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "INFO: Installing Docker Desktop via Homebrew..." >&2
  brew install --cask docker
  echo "INFO: Docker Desktop installed — please start it from Applications before continuing." >&2
else
  echo "INFO: docker already installed ($(docker --version))" >&2
fi

echo "INFO: All prerequisites are satisfied." >&2
