#!/usr/bin/env bash

set -euo pipefail

die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

check_prerequisites() {
    local env_file="$HOME/autonity/.env"

    for cmd in aut jq bc autonity; do
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

select_wallet_from_list() {
    local -a wallets=()
    local -a addresses=()

    local wallet_line address_line
    while IFS= read -r line; do
        if [[ "$line" == *"wallet"* ]]; then
            wallet_line="$line"
        elif [[ "$line" == "Address"* ]]; then
            address_line=$(echo "$line" | awk -F': ' '{print $2}')
            if [[ -n "$wallet_line" && -n "$address_line" ]]; then
                wallets+=("$wallet_line")
                addresses+=("$address_line")
                wallet_line=""
                address_line=""
            fi
        fi
    done < <(autonity wallet info)

    if [[ ${#wallets[@]} -eq 0 ]]; then
        die "No wallets found or failed to parse wallet list."
    fi

    echo "Available Wallets:"
    for i in "${!wallets[@]}"; do
        printf "%d. %s (%s)\n" "$((i + 1))" "${wallets[$i]}" "${addresses[$i]}"
    done

    local choice
    read -p "Choose a wallet (1-${#wallets[@]}): " choice
    if ! [[ "$choice" =~ ^[0-9]+$ && "$choice" -ge 1 && "$choice" -le ${#wallets[@]} ]]; then
        die "Invalid wallet choice."
    fi

    echo "${addresses[$((choice - 1))]}"
}

get_recipient_address() {
    local recipient_address

    echo
    read -p "Choose recipient: from list (1) or enter manually (2)? " choice
    case "$choice" in
    1)
        recipient_address=$(select_wallet_from_list)
        ;;
    2)
        read -p "Enter the recipient's address: " recipient_address
        if ! [[ "$recipient_address" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
            die "Invalid address format."
        fi
        ;;
    *)
        die "Invalid choice."
        ;;
    esac

    echo "$recipient_address"
}

send_transaction() {
    local recipient="$1"
    local amount="$2"
    local currency_type="$3"

    echo
    echo "Preparing to send $amount $currency_type to $recipient..."

    local -a cmd_args
    cmd_args=(aut tx make --to "$recipient" --value "$amount")

    if [[ "$currency_type" == "NTN" ]]; then
        cmd_args+=(--ntn)
    fi

    export KEYFILEPWD="$KEYPASSWORD"

    local tx_hash
    tx_hash=$("${cmd_args[@]}" | aut tx sign - | aut tx send -)

    if [[ -z "$tx_hash" ]]; then
        die "Transaction failed. No transaction hash was returned."
    fi

    echo "Transaction sent successfully."
    echo "Transaction Hash: $tx_hash"
}

main() {
    check_prerequisites

    echo "--- Autonity Wallet Transfer ---"

    local recipient
    recipient=$(get_recipient_address)
    echo "Recipient set to: $recipient"

    local currency_type
    read -p "Choose currency to send (1 for ATN, 2 for NTN): " currency_choice
    case "$currency_choice" in
    1) currency_type="ATN" ;;
    2) currency_type="NTN" ;;
    *) die "Invalid currency selection." ;;
    esac

    local amount
    read -p "Enter the amount of $currency_type to send: " amount
    if ! [[ "$amount" =~ ^[0-9]+([.][0-9]+)?$ && $(bc <<<"$amount > 0") -eq 1 ]]; then
        die "Invalid amount. Please enter a positive number."
    fi

    send_transaction "$recipient" "$amount" "$currency_type"
}

main
