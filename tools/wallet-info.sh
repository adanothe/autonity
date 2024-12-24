#!/bin/bash

DIRECTORY="$HOME/.autonity/keystore/"

find "$DIRECTORY" -type f -name "*.key" -exec sh -c '
    for file; do
        wallet=$(basename "$file" .key) 
        echo "$wallet wallet" 

        account_info=$(aut account info -k "$file" | jq -r ".[0]")
        address=$(echo "$account_info" | jq -r ".account")
        balance=$(echo "$account_info" | jq -r ".balance")
        ntn_balance=$(echo "$account_info" | jq -r ".ntn_balance")

        echo "Address      : $address"
        echo "ATN Balance  : $balance"
        echo "NTN Balance  : $ntn_balance"
        echo "---------------------------------------------------------"
    done
' sh {} +
