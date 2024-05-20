#!/bin/bash

AUTONITY_DIR="$HOME/.autonity"
AUTONITY_KEYS_FILE="$HOME/autonity-chaindata/autonity/autonitykeys"
CURRENT_DATE=$(date +%Y-%m-%d_%H-%M-%S)
AUTONITY_BACKUP_FILENAME="backup-keystore_$CURRENT_DATE.tar.gz"
KEYS_BACKUP_FILENAME="backup-autonitykeys_$CURRENT_DATE.tar.gz"
BACKUP_DIR="$HOME/backups"
mkdir -p "$BACKUP_DIR"

create_backup() {
    local source_dir=$1
    local backup_filename=$2
    tar -czvf "$BACKUP_DIR/$backup_filename" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"
}

create_backup "$AUTONITY_DIR" "$AUTONITY_BACKUP_FILENAME"
create_backup "$AUTONITY_KEYS_FILE" "$KEYS_BACKUP_FILENAME"

if [ $? -eq 0 ]; then
    echo "Backup folder ~/.autonity created successfully: $BACKUP_DIR/$AUTONITY_BACKUP_FILENAME"
    echo "Backup file autonitykeys created successfully: $BACKUP_DIR/$KEYS_BACKUP_FILENAME"
else
    echo "Error: Failed to create backup."
    exit 1
fi

exit 0
