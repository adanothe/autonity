#!/bin/bash

DIRECTORY="$HOME/.autonity/keystore/"

find "$DIRECTORY" -type f -name "*.key" -exec sh -c '
    for file; do
        wallet=$(basename "$file" .key) 
        echo "$wallet wallet" 
        aut account info -k "$file" | jq -r "
            .[0] | 
            \"Address      : \(.account)\",
            \"Balance      : \(.balance)\",
            \"NTN Balance  : \(.ntn_balance)\"
        "
        echo "---------------------------------------------------------"
    done
' sh {} +
