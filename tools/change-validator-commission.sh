#!/bin/bash

AUT_PATH=$(command -v aut)

if [ -z "$AUT_PATH" ]; then
    echo "Error: 'aut' command not found. Make sure it is installed and accessible in your PATH."
    exit 1
fi

source ~/autonity/.env || { echo "Error: Unable to source environment variables from ~/autonity/.env"; exit 1; }

ENODE=$("$AUT_PATH" node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
VALIDATOR_IDENTIFIER_ADDRESS=$("$AUT_PATH" validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*')

read -p "Enter commission rate (1-100): " RATE
COMMISSION_RATE_BPS=$(awk "BEGIN { printf \"%.0f\", $RATE * 100 }")
echo "Commission rate: $RATE%"
echo "Commission rate in basis points: $COMMISSION_RATE_BPS"

echo "Changing commission rate for validator..."
export 'KEYFILEPWD'="$KEYPASSWORD"
"$AUT_PATH" validator change-commission-rate --validator $VALIDATOR_IDENTIFIER_ADDRESS $COMMISSION_RATE_BPS | "$AUT_PATH" tx sign - | "$AUT_PATH" tx send -
echo "Commission rate change completed."
