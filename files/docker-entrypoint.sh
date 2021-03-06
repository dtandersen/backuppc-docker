#!/bin/bash
set -Eeo pipefail

if [ "$1" = 'supervisord' ] && [ "$(id -u)" = '0' ]; then
  mkdir -p "$DATA"
  chown -R 102:102 "$DATA"
  chmod -R 777 "$DATA"
  chmod 777 "$DATA"
#  chmod -R a+rwX "$DATA"
#  chmod 771 "$DATA"
#
#  exec su-exec backuppc "$BASH_SOURCE" "$@"
fi
if [ ! -f /etc/backuppc/config.pl ]; then
  cp /etc/backuppc.sample/config.pl /etc/backuppc/config.pl
fi

if [ ! -f /etc/backuppc/hosts ]; then
  cp /etc/backuppc.sample/hosts /etc/backuppc/hosts
fi
chown -R 102:102  /home/backuppc/.ssh
#if [ ! -f /home/backuppc/.ssh/id_rsa ]; then
#  cp /etc/backuppc.sample/hosts /etc/backuppc/hosts
#fi

#if [ "$1" = 'supervisord' ]; then
#  mkdir -p "$DATA"
#  chown -R "$(id -u)" "$DATA"
#  chmod 777 "$DATA"
#fi

id
pwd
exec "$@"
