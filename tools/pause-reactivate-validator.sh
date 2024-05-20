#!/bin/bash

if ! command -v aut &> /dev/null; then
    echo "Error: 'aut' command not found. Make sure it is installed and accessible in your PATH."
    exit 1
fi

source ~/autonity/.env
AUT_BIN_PATH=$(command -v aut)
ENODE=$("$AUT_BIN_PATH" node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
VALIDATOR_IDENTIFIER_ADDRESS=$("$AUT_BIN_PATH" validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*')

echo "Choose an option to pause or activate the validator:"
echo "1. Activate validator"
echo "2. Pause validator"
read -p "Enter your choice: " choice

case $choice in
    1)
        echo "You have chosen to activate the validator"
        ACTION="activate"
        ;;
    2)
        echo "You have chosen to pause the validator"
        ACTION="pause"
        ;;
    *)
        echo "Invalid choice, exiting."
        exit 1
        ;;
esac

echo "Running $ACTION validator..."
export 'KEYFILEPWD'="$KEYPASSWORD"
"$AUT_BIN_PATH" validator $ACTION --validator $VALIDATOR_IDENTIFIER_ADDRESS | "$AUT_BIN_PATH" tx sign - | "$AUT_BIN_PATH" tx send -
echo "$ACTION validator completed"

STATE=$("$AUT_BIN_PATH" validator info --validator $VALIDATOR_IDENTIFIER_ADDRESS | jq -r '.state')

case $STATE in
    0) echo "Validator is activated";;
    1) echo "Validator is paused";;
    2) echo "Validator is jailed";;
    *) echo "Unknown state";;
esac
