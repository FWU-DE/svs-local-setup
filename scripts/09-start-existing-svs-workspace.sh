#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="${SVS_WORKSPACE_DIR:-$HOME/code/svs}"
RUNTIME_DIR="$WORKSPACE_DIR/.runtime"
LOG_DIR="$RUNTIME_DIR/logs"
PID_DIR="$RUNTIME_DIR/pids"
SKIP_SEED="${SVS_SKIP_SEED:-false}"
SEED_FILES="${SVS_SEED_FILES:-true}"
START_CALENDAR="${SVS_START_CALENDAR:-true}"
START_LEGACY_CLIENT="${SVS_START_LEGACY_CLIENT:-true}"
LEGACY_CLIENT_DIR="${SVS_LEGACY_CLIENT_DIR:-$HOME/code/schulcloud-client}"
SKIP_LEGACY_BUILD="${SVS_SKIP_LEGACY_BUILD:-false}"
MINIO_ROOT_USER="${SVS_MINIO_ROOT_USER:-miniouser}"
MINIO_ROOT_PASSWORD="${SVS_MINIO_ROOT_PASSWORD:-miniouser}"
MINIO_BUCKET="${SVS_MINIO_BUCKET:-schulcloud}"
MINIO_ENDPOINT_FOR_CONTAINER="${SVS_MINIO_ENDPOINT_FOR_CONTAINER:-http://host.docker.internal:9000}"

mkdir -p "$LOG_DIR" "$PID_DIR"

log() {
	printf 'INFO: %s\n' "$*" >&2
}

fail() {
	printf 'ERROR: %s\n' "$*" >&2
	exit 1
}

require_repo() {
	local name="$1"
	[[ -d "$WORKSPACE_DIR/$name/.git" ]] || fail "$WORKSPACE_DIR/$name is missing or not a git repository"
}

require_command() {
	command -v "$1" >/dev/null 2>&1 || fail "Required command '$1' is missing"
}

port_is_listening() {
	local port="$1"
	lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1
}

wait_for_port() {
	local port="$1"
	local label="$2"
	local attempts="${3:-90}"

	for _ in $(seq 1 "$attempts"); do
		if port_is_listening "$port"; then
			log "$label is listening on port $port"
			return 0
		fi
		sleep 2
	done

	fail "$label did not start listening on port $port"
}

start_container() {
	local name="$1"
	local image="$2"
	shift 2

	if docker ps -a --format '{{.Names}}' | grep -Fx "$name" >/dev/null 2>&1; then
		docker start "$name" >/dev/null
		log "Docker container '$name' is running"
		return 0
	fi

	docker run -d --name "$name" "$@" "$image" >/dev/null
	log "Docker container '$name' created from '$image'"
}

node_prefix() {
	if command -v mise >/dev/null 2>&1 && mise ls node 2>/dev/null | grep -Eq '(^|[[:space:]])24\.'; then
		printf 'mise exec node@24 -- '
	else
		printf ''
	fi
}

start_node_service() {
	local name="$1"
	local repo="$2"
	local port="$3"
	shift 3
	local pid_file="$PID_DIR/$name.pid"
	local log_file="$LOG_DIR/$name.log"

	if port_is_listening "$port"; then
		log "$name already appears to be running on port $port"
		return 0
	fi

	if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" >/dev/null 2>&1; then
		log "$name has existing pid $(cat "$pid_file"); waiting for port $port"
		wait_for_port "$port" "$name" 30
		return 0
	fi

	local prefix
	prefix="$(node_prefix)"
	log "Starting $name in $WORKSPACE_DIR/$repo; log: $log_file"
	(
		cd "$WORKSPACE_DIR/$repo"
		exec bash -lc "${prefix}npm run $*"
	) >"$log_file" 2>&1 &
	echo $! >"$pid_file"
	wait_for_port "$port" "$name"
}

start_calendar_server() {
	local calendar_dir="$WORKSPACE_DIR/calendar-server"
	local pid_file="$PID_DIR/calendar-server.pid"
	local log_file="$LOG_DIR/calendar-server.log"

	if [[ "$START_CALENDAR" != "true" ]]; then
		log "Skipping calendar server because SVS_START_CALENDAR=$START_CALENDAR"
		return 0
	fi

	if port_is_listening 3000; then
		log "calendar-server already appears to be running on port 3000"
		return 0
	fi

	if [[ ! -f "$calendar_dir/server.mjs" ]]; then
		log "Skipping calendar-server; $calendar_dir/server.mjs is missing"
		return 0
	fi

	log "Starting calendar-server in $calendar_dir; log: $log_file"
	(
		cd "$calendar_dir"
		exec node server.mjs
	) >"$log_file" 2>&1 &
	echo $! >"$pid_file"
	wait_for_port 3000 calendar-server 30
}

start_legacy_client() {
	local pid_file="$PID_DIR/schulcloud-client.pid"
	local log_file="$LOG_DIR/schulcloud-client.log"

	if [[ "$START_LEGACY_CLIENT" != "true" ]]; then
		log "Skipping legacy client because SVS_START_LEGACY_CLIENT=$START_LEGACY_CLIENT"
		return 0
	fi

	if port_is_listening 3100; then
		log "schulcloud-client already appears to be running on port 3100"
		return 0
	fi

	if [[ ! -d "$LEGACY_CLIENT_DIR/.git" ]]; then
		log "Skipping schulcloud-client; $LEGACY_CLIENT_DIR is missing or not a git repository"
		return 0
	fi

	local prefix
	prefix="$(node_prefix)"
	if [[ ! -d "$LEGACY_CLIENT_DIR/node_modules" ]]; then
		log "Installing schulcloud-client dependencies in $LEGACY_CLIENT_DIR"
		(cd "$LEGACY_CLIENT_DIR" && ${prefix}npm ci)
	fi
	if [[ "$SKIP_LEGACY_BUILD" != "true" ]] && [[ ! -d "$LEGACY_CLIENT_DIR/build/default" ]]; then
		log "Building schulcloud-client assets in $LEGACY_CLIENT_DIR"
		(cd "$LEGACY_CLIENT_DIR" && ${prefix}npm run build)
	fi
	log "Starting schulcloud-client in $LEGACY_CLIENT_DIR; log: $log_file"
	(
		cd "$LEGACY_CLIENT_DIR"
		exec bash -lc "${prefix}npm run start"
	) >"$log_file" 2>&1 &
	echo $! >"$pid_file"
	wait_for_port 3100 schulcloud-client 60
}

seed_file_storage() {
	if [[ "$SEED_FILES" != "true" ]]; then
		log "Skipping file-storage seed because SVS_SEED_FILES=$SEED_FILES"
		return 0
	fi

	log "Seeding local file metadata in MongoDB"
	docker exec mongodb mongosh schulcloud --quiet --eval '
const now = new Date();
const user = db.users.findOne({_id: ObjectId("0000d231816abba584714c9e")}) || db.users.findOne({});
const courses = db.courses.find({}).sort({_id: 1}).limit(10).toArray();
const school = db.schools.findOne({_id: ObjectId("5f2987e020834114b8efd6f8")}) || db.schools.findOne({});
if (!user || courses.length === 0 || !school) {
  throw new Error("Cannot seed file records without at least one user, course and school");
}
const personalNames = [
  "Persönlicher Stundenplan.txt",
  "Notizen Elternabend.txt",
  "Projektideen.txt",
  "Leseliste Deutsch.txt",
  "Mathe Formelsammlung.txt",
  "Präsentation Stichpunkte.txt",
  "Experiment Beobachtungen.txt",
  "Hausaufgaben Checkliste.txt",
  "Lernziele Woche.txt",
  "Portfolio Reflexion.txt"
];
const courseNames = [
  "Kursmaterial Algebra.txt",
  "Arbeitsblatt Lineare Funktionen.txt",
  "Biologie Versuchsanleitung.txt",
  "Physik Optik Zusammenfassung.txt",
  "Deutsch Gedichtanalyse.txt",
  "Erdkunde Kartenübung.txt",
  "Englisch Vocabulary.txt",
  "Geschichte Quellenarbeit.txt",
  "Chemie Laborregeln.txt",
  "Informatik Pseudocode.txt"
];
function oid(prefix, index) {
  return ObjectId(prefix + String(index + 1).padStart(20, "0"));
}
const samples = [
  ...personalNames.map((name, index) => ({
    _id: index === 0 ? ObjectId("6a3b70ad4894bdcd176c0c20") : oid("6a40", index),
    name,
    mimeType: "text/plain",
    parentType: "users",
    parent: user._id,
    creator: user._id,
    storageLocationId: school._id,
    body: `Demo-Datei ${index + 1} im Bereich Persönliche Dateien.\n`
  })),
  ...courseNames.map((name, index) => ({
    _id: index === 0 ? ObjectId("6a3d2232a165b00ececa5bae") : oid("6a41", index),
    name,
    mimeType: "text/plain",
    parentType: "courses",
    parent: courses[index % courses.length]._id,
    creator: user._id,
    storageLocationId: school._id,
    body: `Demo-Kursdatei ${index + 1} für ${courses[index % courses.length].name || "Kurs"}.\n`
  }))
];
for (const sample of samples) {
  db.filerecords.updateOne(
    {_id: sample._id},
    {$set: {
      updatedAt: now,
      size: sample.body.length,
      name: sample.name,
      mimeType: sample.mimeType,
      securityCheck: {
        status: "pending",
        reason: "local development seed",
        requestToken: sample._id.toString(),
        createdAt: now,
        updatedAt: now
      },
      parentType: sample.parentType,
      parent: sample.parent,
      creator: sample.creator,
      storageLocationId: sample.storageLocationId,
      storageLocation: "school",
      storageType: "standard",
      contentLastModifiedAt: now
    }, $setOnInsert: { _id: sample._id, createdAt: now }},
    {upsert: true}
  );
}
print("filerecords=" + db.filerecords.countDocuments({}));
print("personalSeeded=" + db.filerecords.countDocuments({parentType: "users", parent: user._id}));
print("courseSeeded=" + db.filerecords.countDocuments({parentType: "courses"}));
'

	log "Seeding local S3 objects in MinIO bucket '$MINIO_BUCKET'"
	docker run --rm --entrypoint /bin/sh minio/mc -c '
set -eu
endpoint="'"$MINIO_ENDPOINT_FOR_CONTAINER"'"
access_key="'"$MINIO_ROOT_USER"'"
secret_key="'"$MINIO_ROOT_PASSWORD"'"
bucket="'"$MINIO_BUCKET"'"
mc alias set local "$endpoint" "$access_key" "$secret_key" >/dev/null
mc mb -p "local/$bucket" >/dev/null 2>&1 || true
mkdir -p /tmp/svs-seed
seed_object() {
  id="$1"
  body="$2"
  file="/tmp/svs-seed/$id.txt"
  printf "%s\n" "$body" > "$file"
  mc cp "$file" "local/$bucket/5f2987e020834114b8efd6f8/$id" >/dev/null
}
seed_object 6a3b70ad4894bdcd176c0c20 "Demo-Datei 1 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000002 "Demo-Datei 2 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000003 "Demo-Datei 3 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000004 "Demo-Datei 4 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000005 "Demo-Datei 5 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000006 "Demo-Datei 6 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000007 "Demo-Datei 7 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000008 "Demo-Datei 8 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000009 "Demo-Datei 9 im Bereich Persönliche Dateien."
seed_object 6a4000000000000000000010 "Demo-Datei 10 im Bereich Persönliche Dateien."
seed_object 6a3d2232a165b00ececa5bae "Demo-Kursdatei 1."
seed_object 6a4100000000000000000002 "Demo-Kursdatei 2."
seed_object 6a4100000000000000000003 "Demo-Kursdatei 3."
seed_object 6a4100000000000000000004 "Demo-Kursdatei 4."
seed_object 6a4100000000000000000005 "Demo-Kursdatei 5."
seed_object 6a4100000000000000000006 "Demo-Kursdatei 6."
seed_object 6a4100000000000000000007 "Demo-Kursdatei 7."
seed_object 6a4100000000000000000008 "Demo-Kursdatei 8."
seed_object 6a4100000000000000000009 "Demo-Kursdatei 9."
seed_object 6a4100000000000000000010 "Demo-Kursdatei 10."
'
}
require_command docker
require_command lsof
require_command curl
require_repo schulcloud-server
require_repo nuxt-client
require_repo file-storage

docker info >/dev/null 2>&1 || fail "Docker is not running"

start_container mongodb mongo:7 -p 27017:27017
start_container rabbitmq rabbitmq:3.8.9-management -p 5672:5672 -p 15672:15672
start_container svs-redis redis:7-alpine -p 6379:6379
if docker ps -a --format '{{.Names}}' | grep -Fx svs-minio >/dev/null 2>&1; then
	docker start svs-minio >/dev/null
	log "Docker container 'svs-minio' is running"
else
	docker run -d \
		--name svs-minio \
		-p 9000:9000 \
		-p 9001:9001 \
		-e MINIO_ROOT_USER="$MINIO_ROOT_USER" \
		-e MINIO_ROOT_PASSWORD="$MINIO_ROOT_PASSWORD" \
		minio/minio server /data --console-address ':9001' >/dev/null
	log "Docker container 'svs-minio' created from 'minio/minio'"
fi

if [[ "$SKIP_SEED" != "true" ]]; then
	log "Seeding MongoDB via schulcloud-server"
	(cd "$WORKSPACE_DIR/schulcloud-server" && $(node_prefix)npm run setup:db:seed)
	seed_file_storage
else
	log "Skipping DB seed because SVS_SKIP_SEED=true"
fi

start_calendar_server
start_legacy_client
start_node_service backend schulcloud-server 3030 nest:start:dev
start_node_service file-storage file-storage 4444 start:files-storage:dev
start_node_service nuxt-client nuxt-client 4000 'serve -- --host 0.0.0.0'

log "Verifying HTTP endpoints"
curl -fsS http://localhost:3030/api/v3/docs >/dev/null
curl -fsS http://localhost:4444/api/v3/file/docs >/dev/null
curl -fsS http://localhost:4000/ >/dev/null
if [[ "$START_LEGACY_CLIENT" == "true" ]] && [[ -d "$LEGACY_CLIENT_DIR/.git" ]]; then
	curl -fsS http://localhost:3100/ >/dev/null
fi
if [[ "$START_CALENDAR" == "true" ]] && [[ -f "$WORKSPACE_DIR/calendar-server/server.mjs" ]]; then
	curl -fsS http://localhost:3000/events >/dev/null
fi

cat <<EOF
Local SVS stack is running.

Backend:      http://localhost:3030/api/v3/docs
File storage: http://localhost:4444/api/v3/file/docs
Nuxt client:  http://localhost:4000/
Legacy:      http://localhost:3100/
Calendar:     http://localhost:3000/events
Logs:         $LOG_DIR
PIDs:         $PID_DIR
EOF
