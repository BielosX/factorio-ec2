#!/bin/bash

mkdir -p /opt/factorio
cp /tmp/factorio_run.sh /opt/factorio/factorio_run.sh
chmod +x /opt/factorio/factorio_run.sh
cp /tmp/factorio.service /usr/lib/systemd/system/factorio.service
cp /tmp/load_settings.sh /opt/factorio/load_settings.sh
chmod +x /opt/factorio/load_settings.sh
cp /tmp/settings-loader.service /usr/lib/systemd/system/settings-loader.service