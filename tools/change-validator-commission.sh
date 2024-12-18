#!/bin/bash

if ! command -v aut &> /dev/null; then
    echo "Error: 'aut' command not found. Make sure it is installed and accessible in your PATH."
    exit 1
fi

source "$HOME/autonity/.env" || { echo "Error: Unable to source environment variables from $HOME/autonity/.env"; exit 1; }

enode=$(aut node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
validator_address=$(aut validator info | jq -r '.node_address')

read -p "Enter commission rate (1-100): " rate
commission_rate_bps=$(awk "BEGIN { printf \"%.0f\", $rate * 100 }")
echo "Commission rate: $rate%"
echo "Commission rate in basis points: $commission_rate_bps"

echo "Changing commission rate for validator..."
export KEYFILEPWD="$KEYPASSWORD"
aut validator change-commission-rate --validator "$validator_address" "$commission_rate_bps" | aut tx sign - | aut tx send -
echo "Commission rate change completed."
