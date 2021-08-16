#!/bin/bash
FACTORIO_BIN=/opt/factorio/bin/x64/factorio
SAVES_DIR=/opt/factorio/saves
SERVER_SAVE=/opt/factorio/saves/factorio.zip
FIFO_FILE=/var/lib/factorio/factorio.fifo
PID_FILE=/var/lib/factorio/factorio.pid
CMD_OUT=/var/lib/factorio/server.out
SETTINGS_FILE=/etc/factorio/server-settings.json
MAP_GEN=/etc/factorio/map-gen-settings.json
MAP_SETTINGS=/etc/factorio/map-settings.json

if [ ! -e $MAP_GEN ]; then
    echo -e "map-gen-settings.json does not exist!"
    exit 1
fi

if [ ! -e $MAP_SETTINGS ]; then
    echo -e "map-settings.json does not exist!"
    exit 1
fi

if [ ! -e $SETTINGS_FILE ]; then
    echo -e "server-settings.json does not exist!"
    exit 1
fi

if [ ! -e $FIFO_FILE ]; then
    mkfifo $FIFO_FILE
fi

if [ -e $SAVES_DIR ]; then
    if [ ! -e $SERVER_SAVE ]; then
        echo "Save zip not found. Creating one."
        $FACTORIO_BIN --create $SERVER_SAVE --map-gen-settings $MAP_GEN --map-settings $MAP_SETTINGS
        BACKUP_PATH=$(printf "%s.backup_1" $SERVER_SAVE)
        cp $SERVER_SAVE "$BACKUP_PATH"
    fi

    $FACTORIO_BIN --start-server $SERVER_SAVE --server-settings "$SETTINGS_FILE" >> $CMD_OUT 2>&1 & echo $! > $PID_FILE
else
    echo -e "Saves DIR does not exist!"
    exit 1
fi
