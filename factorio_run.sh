#!/bin/bash
FACTORIO_BIN=/opt/factorio/bin/x64/factorio
SAVES_DIR=/opt/factorio_saves
INIT_SAVE=/opt/factorio_saves/init.zip
FIFO_FILE=/var/lib/factorio/factorio.fifo
PID_FILE=/var/lib/factorio/factorio.pid
CMD_OUT=/var/lib/factorio/server.out

mkdir -p /var/lib/factorio

if [ ! -e $FIFO_FILE ]; then
    mkfifo $FIFO_FILE
fi

if [ -e $SAVES_DIR ]; then
    if [ ! -e $INIT_SAVE ]; then
        echo "Init save not found. Creating one."
        $FACTORIO_BIN --create $INIT_SAVE
    fi

    tail -f $FIFO_FILE | $FACTORIO_BIN --start-server $INIT_SAVE >> $CMD_OUT 2>&1 & echo $! > $PID_FILE
else
    echo -e "Saves DIR does not exist!"
    exit 1
fi
