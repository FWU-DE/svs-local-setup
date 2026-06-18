#!/bin/sh

set -eu

CONTAINER_NAME="mongodb"
IMAGE="mongo:7"
PORT="27017"

if docker ps -a --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
	if docker ps --format '{{.Names}}' | grep -Fx "$CONTAINER_NAME" >/dev/null 2>&1; then
		echo "MongoDB is already running in container '$CONTAINER_NAME' on port $PORT"
		exit 0
	fi

	docker start "$CONTAINER_NAME" >/dev/null
	echo "MongoDB restarted in container '$CONTAINER_NAME' on port $PORT"
	exit 0
fi

docker run -d \
	--name "$CONTAINER_NAME" \
	-p "$PORT:27017" \
	"$IMAGE" >/dev/null

echo "MongoDB started in container '$CONTAINER_NAME' on port $PORT using image '$IMAGE'"
