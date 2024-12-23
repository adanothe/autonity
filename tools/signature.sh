#!/bin/bash

display_error() {
    echo "Error: $1" >&2
    exit 1
}

load_env_variables() {
    local env_file="$HOME/autonity/.env"

    if [ -f "$env_file" ]; then
        source "$env_file"
    else
        display_error "File .env not found in $HOME/autonity."
    fi
}

check_aut_command() {
    if ! command -v aut &>/dev/null; then
        display_error "'aut' command not found."
    fi
}

sign_message() {
    local message="$1"
    local keyfile="$HOME/.autonity/keystore/treasury.key"
    local password="$KEYPASSWORD"

    if [ -z "$message" ]; then
        display_error "Message cannot be empty."
    fi

    if [ -z "$password" ]; then
        display_error "Password not found in .env file."
    fi

    local signature
    signature=$(aut account sign-message "$message" --keyfile "$keyfile" --password "$password" 2>/dev/null)
    if [ -z "$signature" ]; then
        display_error "Failed to generate signature."
    fi

    echo "$signature"
}

get_autonity_address() {
    local keyfile="$HOME/.autonity/keystore/treasury.key"

    local autonity_info
    autonity_info=$(aut account info --keyfile "$keyfile" 2>/dev/null)

    local autonity_address
    autonity_address=$(echo "$autonity_info" | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')
    if [ -z "$autonity_address" ]; then
        display_error "Failed to retrieve Autonity address."
    fi

    echo "$autonity_address"
}

main() {
    load_env_variables
    check_aut_command

    echo -n "Enter the message to sign: "
    read -r message

    echo -n "signature hash: "
    sign_message "$message"

    echo -n "sign with address: "
    get_autonity_address
}

main
