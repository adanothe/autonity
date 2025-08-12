#!/usr/bin/env bash

set -euo pipefail

readonly ENV_FILE="$HOME/autonity/.env"
readonly KEYSTORE_DIR="$HOME/.autonity/keystore"

die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

check_prerequisites() {
    for cmd in aut jq; do
        command -v "$cmd" &>/dev/null || die "Command '$cmd' not found. Please install it."
    done

    if [[ ! -f "$ENV_FILE" ]]; then
        die ".env file not found at '$ENV_FILE'."
    fi

    if [[ ! -d "$KEYSTORE_DIR" ]]; then
        die "Keystore directory not found at '$KEYSTORE_DIR'."
    fi
}

select_keyfile() {
    mapfile -d '' keyfiles < <(find "$KEYSTORE_DIR" -type f -name '*.key' -print0)

    if [[ ${#keyfiles[@]} -eq 0 ]]; then
        die "No wallet (.key) files found in '$KEYSTORE_DIR'."
    fi

    echo "Available wallets to sign with:" >&2
    for i in "${!keyfiles[@]}"; do
        printf "%d. %s\n" "$((i + 1))" "$(basename "${keyfiles[$i]}")" >&2
    done

    local choice
    read -p "Choose a wallet (1-${#keyfiles[@]}): " choice

    if ! [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#keyfiles[@]} ]]; then
        die "Invalid wallet choice."
    fi

    echo "${keyfiles[$((choice - 1))]}"
}

get_signing_address() {
    local keyfile="$1"
    aut account info --keyfile "$keyfile" | jq -r '.[0].account'
}

sign_message_with_key() {
    local message="$1"
    local keyfile="$2"

    aut account sign-message "$message" --keyfile "$keyfile"
}

main() {
    check_prerequisites

    source "$ENV_FILE"
    if [[ -z "${KEYPASSWORD:-}" ]]; then
        die "KEYPASSWORD is not set or is empty in '$ENV_FILE'."
    fi

    echo "--- Autonity Message Signing Utility ---"
    echo

    local chosen_keyfile
    chosen_keyfile=$(select_keyfile)

    local address
    address=$(get_signing_address "$chosen_keyfile")
    if [[ -z "$address" ]]; then
        die "Failed to retrieve the signing address from the keyfile."
    fi

    echo
    echo "Using Wallet: $(basename "$chosen_keyfile")"
    echo "Signing Address: $address"
    echo

    local message
    read -p "Enter the message to sign: " message
    if [[ -z "$message" ]]; then
        die "Message cannot be empty."
    fi

    export KEYFILEPWD="$KEYPASSWORD"

    local signature
    signature=$(sign_message_with_key "$message" "$chosen_keyfile")
    if [[ -z "$signature" ]]; then
        die "Failed to generate the signature. Check your password or keyfile."
    fi

    echo
    echo "----------------------------------------"
    echo "Signature Generated Successfully"
    echo "----------------------------------------"
    echo "Address:   $address"
    echo "Signature: $signature"
}

main
