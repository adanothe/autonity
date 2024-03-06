#!/bin/bash

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Get the parent directory of the script
REPO_DIR="autonity"
PARENT_DIR="$HOME/$REPO_DIR"

# Load environment variables from .env file in the parent directory
ENV_FILE="$PARENT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    log_message "Load environment variables"
else
    echo "Error: File .env not found in the parent directory."
    exit 1
fi

# Define the location of aut
AUT=$(which aut)
if [ -z "$AUT" ]; then
    echo "Error: 'aut' command not found."
    exit 1
fi
log_message "Check aut directory"

# Define the location of the key file
KEYFILE="/root/.autonity/keystore/treasury.key"
log_message "Check keyfile directory"

# Define the message to be signed
MESSAGE="I have read and agree to comply with the Piccadilly Circus Games Competition Terms and Conditions published on IPFS with CID QmVghJVoWkFPtMBUcCiqs7Utydgkfe19wkLunhS5t57yEu"
log_message "setup message to be signed"

# Get the password from the environment variable
PASSWORD="$KEYPASSWORD"

# Check if PASSWORD is not empty
if [ -z "$PASSWORD" ]; then
    echo "Error: Password not found in .env file."
    exit 1
fi

# Run the command to sign the message
SIGNED_MESSAGE=$("$AUT" account sign-message "$MESSAGE" --keyfile "$KEYFILE" --password "$PASSWORD" | grep -o '0x[0-9a-fA-F]*')

# Run the command to check autonity address
AUTONITY_ADDRESS=$("$AUT" account info --keyfile "$KEYFILE" | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')

# Display the signed message
echo "SIGNATURE:"
echo "$SIGNED_MESSAGE"
echo "AUTONITY ADDRESS:"
echo "$AUTONITY_ADDRESS"

# Display registration link
echo "Registration Link: https://game.autonity.org/getting-started/register.html"
