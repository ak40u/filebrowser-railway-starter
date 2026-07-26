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

# First boot only. On later boots the database exists and none of this runs, so a
# redeploy does not reset the account, the shares, or the user list.
#
# The database is built at a temporary path and moved into place only once the
# admin account is in it. Doing it in place would be a trap: filebrowser rejects a
# password shorter than 12 characters, and if the account creation failed after
# the file had been created, every later boot would skip this block and start a
# file manager with no accounts at all - unusable, and not obviously so.
if [ ! -f "$DB" ]; then
  TMP_DB="${DB}.init"
  rm -f "$TMP_DB"
  echo "initialising $DB"
  filebrowser config init --database "$TMP_DB" --root "$ROOT_DIR" --log stdout
  filebrowser users add "${ADMIN_USERNAME:-admin}" "$ADMIN_PASSWORD" --perm.admin --database "$TMP_DB"
  mv "$TMP_DB" "$DB"
fi

# Address, port and root are passed on every start rather than stored, so a change
# to the service takes effect without editing the database by hand.
#
# The address is an empty string on purpose. filebrowser builds "address:port" by
# string concatenation, so "::" becomes ":::8080" and Go refuses it; omitting the
# flag falls back to the stored default of 127.0.0.1, which is reachable from
# nothing. Empty gives ":8080" - it binds [::] dual-stack, so both the public
# domain and the private IPv6 network reach it.
#
# --disableExec is this version's default; it is spelled out because the process
# runs as root (the mounted volume is root-owned) and Command Runner would
# otherwise be a root shell behind a login form.
exec filebrowser \
  --database "$DB" \
  --root "$ROOT_DIR" \
  --address "" \
  --port "$PORT" \
  --disableExec \
  --log stdout
