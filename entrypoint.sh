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
# password. On later boots the database already exists and nothing here runs, so a
# redeploy does not reset the account, the shares, or the user list.
if [ ! -f "$DB" ]; then
  echo "initialising $DB"
  filebrowser config init --database "$DB" --root "$ROOT_DIR" --log stdout
  filebrowser users add "${ADMIN_USERNAME:-admin}" "$ADMIN_PASSWORD" --perm.admin --database "$DB"
fi

# Address, port and root are passed on every start rather than stored, so a change
# to the service takes effect without editing the database by hand.
# --disableExec is this version's default; it is spelled out because the process
# runs as root (the mounted volume is root-owned) and Command Runner would
# otherwise be a root shell behind a login form.
exec filebrowser \
  --database "$DB" \
  --root "$ROOT_DIR" \
  --address "::" \
  --port "$PORT" \
  --disableExec \
  --log stdout
