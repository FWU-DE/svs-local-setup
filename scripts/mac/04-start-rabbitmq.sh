#!/bin/sh

set -eu

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew is not installed." >&2
  echo "       Install via: https://brew.sh" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is not installed." >&2
  echo "       Install via: brew install --cask docker" >&2
  exit 1
fi

CONTAINER_NAME="rabbitmq"
IMAGE="rabbitmq:3.8.9-management"

if docker ps -a --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
	if docker ps --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
		echo "RabbitMQ is already running in container '$CONTAINER_NAME'"
		exit 0
	fi

	docker start "$CONTAINER_NAME" >/dev/null
	echo "RabbitMQ restarted in container '$CONTAINER_NAME'"
	exit 0
fi

docker run -d \
	--name "$CONTAINER_NAME" \
	-p 5672:5672 \
	-p 15672:15672 \
	"$IMAGE" >/dev/null

echo "RabbitMQ started in container '$CONTAINER_NAME' using image '$IMAGE'"
