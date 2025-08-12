#!/usr/bin/env bash

set -euo pipefail

die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

check_prerequisites() {
    local keystore_dir="$HOME/.autonity/keystore/"
    
    for cmd in aut jq; do
        command -v "$cmd" &>/dev/null || die "Command '$cmd' not found. Please install it."
    done

    if [[ ! -d "$keystore_dir" ]]; then
        die "Keystore directory not found at '$keystore_dir'."
    fi
}

main() {
    local -r keystore_dir="$HOME/.autonity/keystore/"
    
    check_prerequisites

    echo "--- Autonity Wallet Overview ---"
    echo "Displaying all wallets found in: $keystore_dir"
    
    local keyfiles_found=false
    while IFS= read -r -d '' keyfile; do
        keyfiles_found=true
        local wallet_name
        wallet_name=$(basename "$keyfile" .key)
        
        local account_info
        account_info=$(aut account info -k "$keyfile")

        local address balance ntn_balance
        read -r address balance ntn_balance < <(echo "$account_info" | jq -r '.[0] | "\(.account) \(.balance) \(.ntn_balance)"')

        if [[ -z "$address" ]]; then
            echo "Warning: Could not fetch info for wallet '$wallet_name'. Skipping."
            continue
        fi

        echo
        echo "Wallet Name: $wallet_name"
        echo "Address    : $address"
        echo "ATN Balance: $balance ATN"
        echo "NTN Balance: $ntn_balance NTN"
        echo "---------------------------------------------------------"

    done < <(find "$keystore_dir" -type f -name "*.key" -print0)

    if [[ "$keyfiles_found" == false ]]; then
        echo
        echo "No wallet (.key) files found in $keystore_dir"
    fi
}

main