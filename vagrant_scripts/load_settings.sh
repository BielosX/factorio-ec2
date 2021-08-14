#!/bin/bash

cp /tmp/server-settings.json /etc/factorio/server-settings.json
chown -R factorio:factorio /etc/factorio/server-settings.json
chmod -R g+r /etc/factorio/server-settings.json
cp /tmp/server-adminlist.json /opt/factorio/server-adminlist.json
chown -R factorio:factorio /opt/factorio/server-adminlist.json
chmod -R g+rw /opt/factorio/server-adminlist.json
