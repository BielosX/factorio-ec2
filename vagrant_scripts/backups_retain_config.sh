#!/bin/bash

BACKUPS_RETAIN=$1
if [ -z "$BACKUPS_RETAIN" ]; then
  BACKUPS_RETAIN=10
fi

mkdir -p /usr/lib/systemd/system/backup-on-change.service.d
printf '[Service]\nEnvironment="BACKUPS_RETAIN=%u"' "$BACKUPS_RETAIN" >> /usr/lib/systemd/system/backup-on-change.service.d/override.conf