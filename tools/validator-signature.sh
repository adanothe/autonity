#!/bin/bash

source "$HOME/autonity/.env"

if [ -z "$KEYPASSWORD" ]; then
    echo "Error: KEYPASSWORD is not set in .env file"
    exit 1
fi

echo "Please enter your message to sign:"
read message

autonity_dir="$HOME/autonity"
keystore_dir="$HOME/.autonity/keystore"
keyfile="$keystore_dir/autonitykeys.key"
private_key_file="$keystore_dir/autonitykeys.priv"
autonity_keys_file="$keystore_dir/autonitykeys.key"

import_private_key() {
    echo "$1" >"$private_key_file"
    expect -c "
    spawn aut account import-private-key $private_key_file
    expect \"Password for new account:\"
    send \"$KEYPASSWORD\r\"
    expect \"Confirm account password:\"
    send \"$KEYPASSWORD\r\"
    interact
    " >/dev/null 2>&1
}

if [ -f "$autonity_keys_file" ]; then
    signed_message=$(aut account sign-message "$message" --keyfile "$autonity_keys_file" --password "$KEYPASSWORD")

    if [[ "$signed_message" == *"Error"* ]]; then
        echo "Error during signing message: $signed_message"
        exit 1
    fi

    enode=$(aut node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
    echo "Signature and enode for registration ASDP:"
    echo "Signature: $signed_message"
    echo "enode: $enode"
    exit 0
fi

private_key=$(head -c 64 "$HOME/autonity-chaindata/autonity/autonitykeys")
echo "Importing private key from autonitykeys file"
import_private_key "$private_key"
mv "$keystore_dir/UTC-"* "$keyfile"
chmod 600 "$keyfile"

enode=$(aut node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
signed_message=$(aut account sign-message "$message" --keyfile "$keyfile" --password "$KEYPASSWORD")

if [[ "$signed_message" == *"Error"* ]]; then
    echo "Error during signing message: $signed_message"
    exit 1
fi

echo "Signature and enode:"
echo "Signature: $signed_message"
echo "enode: $enode"
