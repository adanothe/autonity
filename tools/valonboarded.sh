#!/bin/bash

source ~/autonity/.env
HEAD=$(command -v head)
AUT=$(command -v aut)
MESSAGE="validator onboarded"

AUTONITY_DIR="$HOME/autonity"
KEYSTORE_DIR="$HOME/.autonity/keystore"
KEYFILE="$KEYSTORE_DIR/autonitykeys.key"
PRIVATE_KEY_FILE="$KEYSTORE_DIR/autonitykeys.priv"
AUTONITY_KEYS_FILE="$KEYSTORE_DIR/autonitykeys.key"

import_private_key() {
    echo "$1" > "$PRIVATE_KEY_FILE"
    expect -c "
    spawn $AUT account import-private-key $PRIVATE_KEY_FILE
    expect \"Password for new account:\"
    send \"$KEYPASSWORD\r\"
    expect \"Confirm account password:\"
    send \"$KEYPASSWORD\r\"
    interact
    " > /dev/null 2>&1
}

if [ -f "$AUTONITY_KEYS_FILE" ]; then
    SIGNED_MESSAGE=$("$AUT" account sign-message "$MESSAGE" --keyfile "$AUTONITY_KEYS_FILE" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
    ENODE=$("$AUT" validator info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
    echo "Signature and ENODE for registration of onboarded validator:"
    echo "Signature: $SIGNED_MESSAGE"
    echo "ENODE: $ENODE"
    exit 0
fi

private_key=$("$HEAD" -c 64 "$AUTONITY_DIR/autonity-chaindata/autonity/autonitykeys")
echo "Importing private key from autonitykeys file"
import_private_key "$private_key"
mv "$KEYSTORE_DIR/UTC-"* "$KEYFILE"
echo "Successfully imported private key to autonitykeys.key in $KEYFILE"
chmod 600 "$KEYFILE"

ENODE=$("$AUT" validator info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
SIGNED_MESSAGE=$("$AUT" account sign-message "$MESSAGE" --keyfile "$KEYFILE" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
echo "Signature and ENODE for registration of onboarded validator:"
echo "Signature: $SIGNED_MESSAGE"
echo "ENODE: $ENODE"
