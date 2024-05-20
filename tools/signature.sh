#!/bin/bash

display_error() {
    echo "Error: $1"
    exit 1
}

load_env_variables() {
    local repo_dir="autonity"
    local parent_dir="$HOME/$repo_dir"
    local env_file="$parent_dir/.env"

    if [ -f "$env_file" ]; then
        source "$env_file"
    else
        display_error "File .env not found in the parent directory."
    fi
}

check_aut_command() {
    local aut_command=$(which aut)
    if [ -z "$aut_command" ]; then
        display_error "'aut' command not found."
    fi
}

sign_message() {
    local message="I have read and agree to comply with the Piccadilly Circus Games Competition Terms and Conditions published on IPFS with CID QmVghJVoWkFPtMBUcCiqs7Utydgkfe19wkLunhS5t57yEu"
    local keyfile="/root/.autonity/keystore/treasury.key"
    local password="$KEYPASSWORD"

    if [ -z "$password" ]; then
        display_error "Password not found in .env file."
    fi

    local signed_message=$(aut account sign-message "$message" --keyfile "$keyfile" --password "$password" | grep -o '0x[0-9a-fA-F]*')
    echo "$signed_message"
}

get_autonity_address() {
    local keyfile="/root/.autonity/keystore/treasury.key"
    local autonity_address=$(aut account info --keyfile "$keyfile" | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')
    echo "$autonity_address"
}

main() {
    load_env_variables
    check_aut_command

    echo "SIGNATURE:"
    signed_message=$(sign_message)
    echo "$signed_message"

    echo "AUTONITY ADDRESS:"
    autonity_address=$(get_autonity_address)
    echo "$autonity_address"

    echo "Registration Link: https://game.autonity.org/getting-started/register.html"
}

main
