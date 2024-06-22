#!/bin/bash

autonity_dir="$HOME/.autonity"
autonity_keys_file="$HOME/autonity-chaindata/autonity/autonitykeys"
current_date=$(date +%Y-%m-%d_%H-%M-%S)
autonity_backup_filename="backup-keystore_$current_date.tar.gz"
keys_backup_filename="backup-autonitykeys_$current_date.tar.gz"
backup_dir="$HOME/backups"
mkdir -p "$backup_dir"

create_backup() {
    local source_dir=$1
    local backup_filename=$2
    tar -czvf "$backup_dir/$backup_filename" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"
}

create_backup "$autonity_dir" "$autonity_backup_filename"
create_backup "$autonity_keys_file" "$keys_backup_filename"

if [ $? -eq 0 ]; then
    echo "Backup folder ~/.autonity created successfully: $backup_dir/$autonity_backup_filename"
    echo "Backup file autonitykeys created successfully: $backup_dir/$keys_backup_filename"
else
    echo "Error: Failed to create backup."
    exit 1
fi

exit 0
