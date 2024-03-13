#!/bin/bash

AUTONITY_DIR="$HOME/.autonity"
AUTONITY_KEYS_FILE="$HOME/autonity-chaindata/autonity/autonitykeys"
AUTONITY_BACKUP_FILENAME="backup-keystore_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
KEYS_BACKUP_FILENAME="backup-autonitykeys_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
BACKUP_DIR="$HOME/backups"

mkdir -p "$BACKUP_DIR"

tar -czvf "$BACKUP_DIR/$AUTONITY_BACKUP_FILENAME" -C "$(dirname "$AUTONITY_DIR")" "$(basename "$AUTONITY_DIR")"
tar -czvf "$BACKUP_DIR/$KEYS_BACKUP_FILENAME" -C "$(dirname "$AUTONITY_KEYS_FILE")" "$(basename "$AUTONITY_KEYS_FILE")"

# Check if backup creation is successful
if [ $? -eq 0 ]; then
    echo "Backup folder ~/.autonity created successfully: $BACKUP_DIR/$AUTONITY_BACKUP_FILENAME"
    echo "Backup file autonitykeys created successfully: $BACKUP_DIR/$KEYS_BACKUP_FILENAME"
else
    echo "Error: Failed to create backup."
    exit 1
fi

exit 0
