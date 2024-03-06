#!/bin/bash

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Get the parent directory of the script
REPO_DIR="autonity"
PARENT_DIR="/root/$REPO_DIR"
log_message "Parent directory set to: $PARENT_DIR"

# Load environment variables from .env file in the parent directory
ENV_FILE="$PARENT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    log_message "Environment variables loaded from: $ENV_FILE"
else
    log_message "Error: File .env not found in the parent directory."
    exit 1
fi

# Read the value of KEYPASSWORD from the .env file
KEYPASSWORD=$(awk -F= '/KEYPASSWORD/ {print $2}' "$ENV_FILE")
log_message "KEYPASSWORD read from .env file"

# Define the location of HEAD
HEAD=$(which head)
log_message "HEAD location: $HEAD"

# Define the location of aut
AUT=$(which aut)
log_message "AUT location: $AUT"

# Define the message to be signed
MESSAGE="validator onboarded"
log_message "Message to be signed: $MESSAGE"

# Get the autonitykeys private key
private_key=$("$HEAD" -c 64 "$HOME/autonity-chaindata/autonity/autonitykeys")
log_message "Private key obtained"

# Create the privacy file with the private key using echo
echo "$private_key" > "$HOME/.autonity/keystore/autonitykeys.priv"
log_message "Private key saved to file: $HOME/.autonity/keystore/autonitykeys.priv"

# Define the location of the key file
KEYFILE="/root/.autonity/keystore/autonitykeys.key"

# Run the expect command to import the private key, redirecting its output to /dev/null
expect -c "
spawn \"$AUT\" account import-private-key \"$HOME/.autonity/keystore/autonitykeys.priv\"
expect \"Password for new account:\"
send \"$KEYPASSWORD\\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\\r\"
interact
" >/dev/null

log_message "Private key imported"

# Wait a moment for the synchronization process
sleep 5
log_message "Waited for synchronization"

# Rename the file
mv "$HOME/.autonity/keystore/UTC-"* "$HOME/.autonity/keystore/autonitykeys.key"
log_message "Key file renamed"

# Provide the appropriate permissions
chmod 600 "$HOME/.autonity/keystore/autonitykeys.key"
log_message "Permissions set for key file"

# Run the command to sign the message
SIGNED_MESSAGE=$("$AUT" account sign-message "$MESSAGE" --keyfile "$KEYFILE" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
log_message "Message signed"

# Display the signed message
echo "Use this signature for registration onboarded validator:"
echo "$SIGNED_MESSAGE"
