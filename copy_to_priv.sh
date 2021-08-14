#!/bin/bash

mkdir -p /opt/factorio
cp /tmp/factorio_run.sh /opt/factorio/factorio_run.sh
chmod +x /opt/factorio/factorio_run.sh
cp /tmp/factorio.service /usr/lib/systemd/system/factorio.service