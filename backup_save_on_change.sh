#!/bin/bash
SERVER_SAVE=/opt/factorio/saves/factorio.zip

if [ -z "$BACKUPS_RETAIN" ]; then
  BACKUPS_RETAIN=10
  echo "BACKUPS_RETAIN env var not set. Using default value ${BACKUPS_RETAIN}"
fi

echo "BACKUPS_RETAIN is set to ${BACKUPS_RETAIN}"

if [ ! -e "$SERVER_SAVE" ]; then
    echo -e "$SERVER_SAVE does not exist!"
    exit 1
else
    while ! inotifywait -e close_write $SERVER_SAVE; do
        echo "$SERVER_SAVE modified! Backup in progress..."
        BACKUP_FILES=($(find /opt/factorio/saves -name "factorio.zip.backup_*"))
        LEN=${#BACKUP_FILES[@]}
        if (( LEN < BACKUPS_RETAIN )); then
            NEXT_SUFFIX=$((LEN + 1))
            BACKUP_FILE=$(printf "%s.backup_%u" $SERVER_SAVE $NEXT_SUFFIX)
            cp $SERVER_SAVE "$BACKUP_FILE"
        else
            OLDEST=${BACKUP_FILES[0]}
            OLDEST_TIMESTAMP=$(stat -c %Y "$OLDEST")
            for file in "${BACKUP_FILES[@]}"; do
                TIMESTAMP=$(stat -c %Y "$file")
                if ((TIMESTAMP < OLDEST_TIMESTAMP)); then
                    OLDEST=$file
                    OLDEST_TIMESTAMP=$TIMESTAMP
                fi
            done
            cp $SERVER_SAVE "$OLDEST"
        fi
    done
fi