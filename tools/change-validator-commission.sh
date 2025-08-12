#!/usr/bin/env bash

set -euo pipefail

check_prerequisites() {
    local env_file="$HOME/autonity/.env"

    for cmd in aut jq bc; do
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

main() {
    check_prerequisites

    local validator_address
    validator_address=$(aut validator info | jq -r '.node_address')
    if [[ -z "$validator_address" ]]; then
        die "Could not retrieve the default validator address."
    fi

    echo "Default Validator Address: $validator_address"
    echo

    local rate
    read -p "Enter new commission rate (e.g., 5 for 5%): " rate

    if ! [[ "$rate" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        die "Invalid input. Commission rate must be a number."
    fi

    if (($(bc <<<"$rate < 0 || $rate > 100"))); then
        die "Invalid range. Commission rate must be between 0 and 100."
    fi

    local commission_rate_bps
    commission_rate_bps=$(printf "%.0f" "$(bc <<<"$rate * 100")")

    echo "Updating validator commission rate to $rate% ($commission_rate_bps basis points)..."

    export KEYFILEPWD="$KEYPASSWORD"

    local tx_hash
    tx_hash=$(aut validator change-commission-rate --validator "$validator_address" "$commission_rate_bps" | aut tx sign - | aut tx send -)

    if [[ -z "$tx_hash" ]]; then
        die "Transaction failed. No transaction hash was returned."
    fi

    echo "Process completed successfully."
    echo "Transaction Hash: $tx_hash"
}

main
