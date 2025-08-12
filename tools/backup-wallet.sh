#!/usr/bin/env bash

set -euo pipefail

main() {
    echo "Starting backup process..."

    local -r backup_base_dir="$HOME/backups"
    local -r current_timestamp
    current_timestamp=$(date +%Y-%m-%d_%H-%M-%S)

    mkdir -p "$backup_base_dir"

    declare -A backup_targets
    backup_targets=(
        ["$HOME/.autonity"]="backup-autonity-dir_${current_timestamp}.tar.gz"
        ["$HOME/autonity-chaindata/autonity/autonitykeys"]="backup-autonitykeys-file_${current_timestamp}.tar.gz"
    )

    local all_successful=true

    for source_path in "${!backup_targets[@]}"; do
        local backup_filename="${backup_targets[$source_path]}"
        local full_backup_path="$backup_base_dir/$backup_filename"

        echo
        echo "Processing: $source_path"

        if [[ ! -e "$source_path" ]]; then
            echo "Warning: Source path does not exist. Skipping."
            all_successful=false
            continue
        fi

        tar -czf "$full_backup_path" -C "$(dirname "$source_path")" "$(basename "$source_path")"

        if [[ -f "$full_backup_path" ]]; then
            echo "Success: Backup created at $full_backup_path"
        else
            echo "Error: Failed to create backup for $source_path"
            all_successful=false
        fi
    done

    echo
    if [[ "$all_successful" == true ]]; then
        echo "All backup tasks completed successfully."
    else
        echo "One or more backup tasks had issues."
        exit 1
    fi
}

main
