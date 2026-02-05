#!/bin/sh
set -e

APP_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

UID_VAL=$(id -u)
GID_VAL=$(id -g)

printf "UID=%s\nGID=%s\n" "$UID_VAL" "$GID_VAL" > "$APP_ROOT/.env"
echo "Wrote $APP_ROOT/.env (UID=$UID_VAL GID=$GID_VAL)"

if [ "$#" -eq 0 ]; then
  set -- up -d
fi

cd "$APP_ROOT"
docker compose "$@"
