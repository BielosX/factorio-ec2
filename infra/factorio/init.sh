#!/bin/bash

FS_TYPE=$(lsblk -o FSTYPE -n /dev/sdf)
DEV_NAME=$(lsblk -o NAME -n /dev/sdf)
DEV_PATH=$(printf "/dev/%s" "$DEV_NAME")

if [ ! "xfs" = "$FS_TYPE" ]; then
  mkfs -t xfs /dev/sdf
fi

if ! mount | grep "/opt/factorio_saves"; then
  mkdir -p /opt/factorio_saves
  chown -R factorio:factorio /opt/factorio_saves
  chmod -R g+rwx /opt/factorio_saves
  UUID=$(blkid "$DEV_PATH" | grep -oP 'UUID="\K([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})')
  FSTAB_LINE=$(printf "UUID=%s  /opt/factorio_saves  xfs  defaults,nofail  0  2" "$UUID")
  echo "$FSTAB_LINE" >> /etc/fstab
  mount -a
fi
