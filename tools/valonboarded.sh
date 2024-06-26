#!/bin/bash

source ~/autonity/.env
head=$(command -v head)
aut=$(command -v aut)
message="Application for the stake delegation program"

autonity_dir="$HOME/autonity"
keystore_dir="$HOME/.autonity/keystore"
keyfile="$keystore_dir/autonitykeys.key"
private_key_file="$keystore_dir/autonitykeys.priv"
autonity_keys_file="$keystore_dir/autonitykeys.key"

import_private_key() {
    echo "$1" > "$private_key_file"
    expect -c "
    spawn $aut account import-private-key $private_key_file
    expect \"Password for new account:\"
    send \"$KEYPASSWORD\r\"
    expect \"Confirm account password:\"
    send \"$KEYPASSWORD\r\"
    interact
    " > /dev/null 2>&1
}

if [ -f "$autonity_keys_file" ]; then
    signed_message=$("$aut" account sign-message "$message" --keyfile "$autonity_keys_file" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
    validator_address=$("$aut" validator info | jq -r '.node_address')
    echo "Signature and validator address for registration ASDP:"
    echo "Signature: $signed_message"
    echo "Validator address: $validator_address"
    exit 0
fi

private_key=$("$head" -c 64 "$HOME/autonity-chaindata/autonity/autonitykeys")
echo "Importing private key from autonitykeys file"
import_private_key "$private_key"
mv "$keystore_dir/UTC-"* "$keyfile"
echo "Successfully imported private key to autonitykeys.key in $keyfile"
chmod 600 "$keyfile"

validator_address=$("$aut" validator info | jq -r '.node_address')
signed_message=$("$aut" account sign-message "$message" --keyfile "$keyfile" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
echo "Signature and validator address for registration ASDP:"
echo "Signature: $signed_message"
echo "Validator address: $validator_address"
