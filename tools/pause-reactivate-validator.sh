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

perform_validator_action() {
    local action="$1"
    local validator_address="$2"
    local action_ing

    action_ing="$(tr '[:lower:]' '[:upper:]' <<<"${action:0:1}")${action:1}ing"

    echo
    echo "Processing: $action_ing validator $validator_address..."

    export KEYFILEPWD="$KEYPASSWORD"

    local tx_hash
    tx_hash=$(aut validator "$action" --validator "$validator_address" | aut tx sign - | aut tx send -)

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

    echo "Operating on Validator: $validator_address"
    echo
    echo "Choose an action:"
    echo "1. Activate validator"
    echo "2. Pause validator"
    read -p "Enter your choice [1-2]: " choice

    local action
    case "$choice" in
    1) action="activate" ;;
    2) action="pause" ;;
    *) die "Invalid choice. Please enter 1 or 2." ;;
    esac

    perform_validator_action "$action" "$validator_address"

    echo
    echo "Please wait until the next epoch for the status change to be reflected on-chain."
}

main
read -p $'\nPress Enter to exit.' -n1