#!/bin/sh
set -e

DB="${FB_DATABASE:-/data/filebrowser.db}"
ROOT_DIR="${FB_ROOT:-/data/files}"
PORT="${PORT:-8080}"

if [ -z "$ADMIN_PASSWORD" ]; then
  echo "ADMIN_PASSWORD is not set - refusing to start a file manager with the stock admin/admin login" >&2
  exit 1
fi

mkdir -p "$(dirname "$DB")" "$ROOT_DIR"

# First boot only: create the database, then the admin account with the supplied
# password. On later boots the database already exists and nothing is touched, so
# a redeploy does not reset the account or the shares.
if [ ! -f "$DB" ]; then
  echo "initialising $DB"
  filebrowser config init --database "$DB" --root "$ROOT_DIR" --address 0.0.0.0 --port "$PORT" --log stdout
  filebrowser users add "${ADMIN_USERNAME:-admin}" "$ADMIN_PASSWORD" --perm.admin --database "$DB"
else
  # Port and root can change between deploys; keep the stored config in step.
  filebrowser config set --database "$DB" --root "$ROOT_DIR" --address 0.0.0.0 --port "$PORT" >/dev/null
fi

exec filebrowser --database "$DB" --root "$ROOT_DIR" --address 0.0.0.0 --port "$PORT" --log stdout
