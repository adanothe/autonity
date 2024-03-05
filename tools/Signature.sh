#!/bin/bash

# Get the parent directory of the script
REPO_DIR="autonity"
PARENT_DIR="$(dirname "$(pwd)/$REPO_DIR")"

# Load environment variables from .env file in the parent directory
ENV_FILE="$PARENT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Error: File .env not found in the parent directory."
    exit 1
fi

# Define the location of aut
AUT="/root/.local/bin/aut"

# Define the location of the key file
KEYFILE="/root/.autonity/keystore/treasury.key"

# Define the message to be signed
MESSAGE="I have read and agree to comply with the Piccadilly Circus Games Competition Terms and Conditions published on IPFS with CID QmVghJVoWkFPtMBUcCiqs7Utydgkfe19wkLunhS5t57yE"

# Get the password from the environment variable
PASSWORD="$KEYPASSWORD"

# Check if PASSWORD is not empty
if [ -z "$PASSWORD" ]; then
    echo "Error: Password not found in .env file."
    exit 1
fi

# Run the command to sign the message
SIGNED_MESSAGE=$("$AUT" account sign-message "$MESSAGE" --keyfile "$KEYFILE" --password "$PASSWORD" | grep -o '0x[0-9a-fA-F]*')

# Display the signed message
echo "Use this signature for registration:"
echo "$SIGNED_MESSAGE"
