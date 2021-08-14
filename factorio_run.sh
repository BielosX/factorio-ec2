#!/bin/bash
FACTORIO_BIN=/opt/factorio/bin/x64/factorio
SAVES_DIR=/opt/factorio/saves
INIT_SAVE=/opt/factorio/saves/init.zip
FIFO_FILE=/var/lib/factorio/factorio.fifo
PID_FILE=/var/lib/factorio/factorio.pid
CMD_OUT=/var/lib/factorio/server.out
SETTINGS_FILE=/etc/factorio/server-settings.json

if [ ! -e $FIFO_FILE ]; then
    mkfifo $FIFO_FILE
fi

if [ -e $SAVES_DIR ]; then
    if [ ! -e $INIT_SAVE ]; then
        echo "Init save not found. Creating one."
        $FACTORIO_BIN --create $INIT_SAVE
    fi

    $FACTORIO_BIN --start-server-load-latest --server-settings "$SETTINGS_FILE" >> $CMD_OUT 2>&1 & echo $! > $PID_FILE
else
    echo -e "Saves DIR does not exist!"
    exit 1
fi
