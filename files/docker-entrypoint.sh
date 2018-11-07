#!/bin/bash
set -Eeo pipefail

#if [ "$1" = 'supervisord' ] && [ "$(id -u)" = '0' ]; then
#  mkdir -p "$DATA"
#  chown -R backuppc "$DATA"
#  chmod 700 "$DATA"
#
#  exec su-exec backuppc "$BASH_SOURCE" "$@"
#fi

if [ "$1" = 'supervisord' ]; then
  mkdir -p "$DATA"
  chown -R "$(id -u)" "$DATA"
  chmod 700 "$DATA"
fi
id
pwd
exec "$@"
