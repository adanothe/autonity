#!/usr/bin/env bash

set -euo pipefail

check_prerequisites() {
    local env_file="$HOME/autonity/.env"

    for cmd in aut jq; do
        command -v "$cmd" &>/dev/null || die "Command '$cmd' not found. Please install it."
    done

    if [[ ! -f "$env_file" ]]; then
        die ".env file not found at '$env_file'."
    fi

    source "$env_file"

    if [[ -z "${KEYPASSWORD:-}" ]]; then
        die "KEYPASSWORD is not set or is empty in '$env_file'."
    fi
}

die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

perform_validation_action() {
    local action="$1"
    local amount="$2"
    local validator_address="$3"
    local action_ing

    action_ing="$(tr '[:lower:]' '[:upper:]' <<< "${action:0:1}")${action:1}ing"

    echo
    echo "Processing: $action_ing $amount NTN for validator $validator_address..."

    export KEYFILEPWD="$KEYPASSWORD"

    local tx_hash
    tx_hash=$(aut validator "$action" --validator "$validator_address" "$amount" | aut tx sign - | aut tx send -)

    if [[ -z "$tx_hash" ]]; then
        die "Transaction failed. No transaction hash was returned."
    fi
    
    echo "Process completed successfully."
    echo "Transaction Hash: $tx_hash"
}

main() {
    check_prerequisites
    
    local validator_address
    validator_address=$(aut validator info | jq -r '.node_address')
    if [[ -z "$validator_address" ]]; then
        die "Could not retrieve the default validator address."
    fi
    
    echo "Default Validator Address: $validator_address"
    echo
    echo "Choose an action:"
    echo "1. Bond (Stake)"
    echo "2. Unbond (Unstake)"
    read -p "Enter your choice [1-2]: " choice

    local action
    case "$choice" in
        1) action="bond" ;;
        2) action="unbond" ;;
        *) die "Invalid choice. Please enter 1 or 2." ;;
    esac

    local amount
    read -p "Enter amount in NTN: " amount
    if ! [[ "$amount" =~ ^[0-9]+([.][0-9]+)?$ && $(bc <<< "$amount > 0") -eq 1 ]]; then
        die "Invalid amount. Please enter a positive number."
    fi

    perform_validation_action "$action" "$amount" "$validator_address"
}

main