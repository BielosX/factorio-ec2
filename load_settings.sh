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
