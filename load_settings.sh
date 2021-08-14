#!/bin/bash

BUCKET=$(cat /etc/factorio/bucket.conf)
S3_ADDR=$(printf "s3://%s/server-settings.json" "$BUCKET")
aws s3 cp "$S3_ADDR" /etc/factorio/server-settings.json
chown -R factorio:factorio /etc/factorio/server-settings.json
chmod -R g+r /etc/factorio/server-settings.json
S3_ADMINLIST=$(printf "s3://%s/server-adminlist.json" "$BUCKET")
aws s3 cp "$S3_ADMINLIST" /opt/factorio/server-adminlist.json
chown -R factorio:factorio /opt/factorio/server-adminlist.json
chmod -R g+rw /opt/factorio/server-adminlist.json
S3_MAP_GEN=$(printf "s3://%s/map-gen-settings.json" "$BUCKET")
aws s3 cp "$S3_MAP_GEN" /etc/factorio/map-gen-settings.json
chown -R factorio:factorio /etc/factorio/map-gen-settings.json
chmod -R g+rw /etc/factorio/map-gen-settings.json
S3_MAP_SETTINGS=$(printf "s3://%s/map-settings.json" "$BUCKET")
aws s3 cp "$S3_MAP_SETTINGS" /etc/factorio/map-settings.json
chown -R factorio:factorio /etc/factorio/map-settings.json
chmod -R g+rw /etc/factorio/map-settings.json
