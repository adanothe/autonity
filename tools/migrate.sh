#!/bin/bash

# Load environment variables
source "$HOME/autonity/.env"

# Set variables
autonity_dir="$HOME/.autonity"
autonity_keys_file="$HOME/autonity-chaindata/autonity/autonitykeys"
current_date=$(date +%Y-%m-%d_%H-%M-%S)
autonity_backup_filename="backup-keystore_$current_date.tar.gz"
keys_backup_filename="backup-autonitykeys_$current_date.tar.gz"
backup_dir="$HOME/backups"
aut=$(command -v aut)
autonity_abi="$HOME/autonity/abi/Autonity.abi"
contract_address="0xBd770416a3345F91E4B34576cb804a576fa48EB1"
node_address=$($aut validator info | jq -r '.node_address' | tr '[:upper:]' '[:lower:]')
enode=$($aut node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')

# Create backup directory if not exists
mkdir -p "$backup_dir"

# Function to create a backup
create_backup() {
    local source=$1
    local backup_filename=$2
    tar -czvf "$backup_dir/$backup_filename" -C "$(dirname "$source")" "$(basename "$source")" >/dev/null 2>&1
}

# Create backups
create_backup "$autonity_dir" "$autonity_backup_filename"
create_backup "$autonity_keys_file" "$keys_backup_filename"

# Pause validator
export KEYFILEPWD="$KEYPASSWORD"
$aut validator pause --validator "$node_address" | $aut tx sign - | $aut tx send - >/dev/null 2>&1

# Change IP
read -p "Enter new IP: " new_ip
new_enode=$(echo "$enode" | sed -E "s/@[0-9.]+:/@$new_ip:/")

# Update enode
export KEYFILEPWD="$KEYPASSWORD"
$aut contract tx --abi "$autonity_abi" --address "$contract_address" updateEnode "$node_address" "$new_enode" >/dev/null 2>&1

# Indicate completion
echo "Validator paused and enode updated successfully."
echo "Backup files created in $backup_dir with filenames: $autonity_backup_filename, $keys_backup_filename"
echo "please continue with the migration process."

exit 0
