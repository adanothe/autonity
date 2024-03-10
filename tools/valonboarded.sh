#!/bin/bash

# Load password from .env file
source ~/autonity/.env

# Path to packages installed
HEAD=$(which head)
AUT=$(which aut)
MESSAGE="validator onboarded"

# Check if the autonitykeys.key files exist next to run the command to sign the message
if [ -f "$HOME/.autonity/keystore/autonitykeys.key" ]; then
    SIGNED_MESSAGE=$("$AUT" account sign-message "$MESSAGE" --keyfile "$HOME/.autonity/keystore/autonitykeys.key" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
    ENODE=$($AUT validator info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
    echo "Use this signature and enode for registration onboarded validator:"
    echo "$SIGNED_MESSAGE"
    echo "ENODE: $ENODE"
    exit 0
fi

# Get the autonitykeys private key
private_key=$("$HEAD" -c 64 "$HOME/autonity-chaindata/autonity/autonitykeys")
echo "import private key from autonitykeys file"

# Create the privacy file with the private key using echo
echo "$private_key" > "$HOME/.autonity/keystore/autonitykeys.priv"
echo "successfully create autonitykeys.priv file in path $HOME/.autonity/keystore/autonitykeys.priv"

# Define the location of the key file
KEYFILE="/root/.autonity/keystore/autonitykeys.key"

# Run the expect command to import the private key
expect -c "
spawn $AUT account import-private-key $HOME/.autonity/keystore/autonitykeys.priv 
expect \"Password for new account:\"
send \"$KEYPASSWORD\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\r\"
interact
" > /dev/null 2>&1


mv "$HOME/.autonity/keystore/UTC-"* "$HOME/.autonity/keystore/autonitykeys.key"
echo "successfully import private key to autonitykeys.key file in path $HOME/.autonity/keystore/autonitykeys.key"

# Provide the appropriate permissions
chmod 600 "$HOME/.autonity/keystore/autonitykeys.key"

# check ENODE
ENODE=$($AUT validator info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')

# Run the command to sign the message
SIGNED_MESSAGE=$("$AUT" account sign-message "$MESSAGE" --keyfile "$KEYFILE" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
echo "Use this signature and enode for registration onboarded validator:"
echo "$SIGNED_MESSAGE"
echo "ENODE: $ENODE"
