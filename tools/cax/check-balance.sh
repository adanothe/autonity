#!/bin/bash

source $HOME/autonity/.env

response=$(http GET "https://cax.piccadilly.autonity.org/api/balances/" "API-Key:$APIKEY")

print_balance() {
    local symbol=$1
    local balance=$(echo "$response" | jq -r --arg sym "$symbol" '.[] | select(.symbol == $sym) | .balance')
    local available=$(echo "$response" | jq -r --arg sym "$symbol" '.[] | select(.symbol == $sym) | .available')
    
    echo "$symbol Balance: $balance"
    echo "$symbol avaible balance: $available"
    echo
}

clear

if [[ -z "$response" ]]; then
    echo "Failed to retrieve balance information. Please check your internet connection or API settings."
    exit 1
fi

print_balance "ATN"
print_balance "NTN"
print_balance "USD"
