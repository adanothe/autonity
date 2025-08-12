#!/usr/bin/env bash

set -euo pipefail

readonly TOOLS_DIR="${HOME}/autonity/tools"
readonly ENV_FILE="${HOME}/autonity/.env"
readonly KEYSTORE_DIR="${HOME}/.autonity/keystore"

die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

check_prerequisites() {
    for cmd in aut ethkey expect jq; do
        command -v "$cmd" &>/dev/null || die "Command '$cmd' not found. Please install it."
    done

    if [[ ! -f "$ENV_FILE" ]]; then
        die ".env file not found at '$ENV_FILE'."
    fi
    source "$ENV_FILE"

    if [[ -z "${KEYPASSWORD:-}" ]]; then
        die "KEYPASSWORD is not set or is empty in '$ENV_FILE'."
    fi
    if [[ -z "${RPC_URL:-}" ]]; then
        die "RPC_URL is not set or is empty in '$ENV_FILE'."
    fi

    mkdir -p "$KEYSTORE_DIR"
}

show_menu() {
    cat <<EOF
===== Wallet Menu =====
1. Create new wallet
2. Import wallet using private key
3. Export private key from existing wallet
4. Show wallet info
5. Create signature message
6. Backup wallet
7. Create transaction
0. Exit
=======================
EOF
}

select_keyfile() {
    mapfile -d '' keyfiles < <(find "$KEYSTORE_DIR" -type f -name '*.key' -print0)

    if [[ ${#keyfiles[@]} -eq 0 ]]; then
        die "No wallet (.key) files found in '$KEYSTORE_DIR'."
    fi

    echo "Available wallets:" >&2
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

create_wallet() {
    echo "--- Create New Wallet ---"
    read -p "Enter the name for the new wallet: " wallet_name
    if [[ -z "$wallet_name" ]]; then
        die "Wallet name cannot be empty."
    fi

    local keyfile_path="${KEYSTORE_DIR}/${wallet_name}.key"
    if [[ -f "$keyfile_path" ]]; then
        die "A wallet file named '${wallet_name}.key' already exists."
    fi

    local creation_output
    creation_output=$(expect << EOF
    set timeout 20
    spawn aut account new -k "$keyfile_path"
    expect "Password for new account:"
    send -- "$KEYPASSWORD\r"
    expect "Confirm account password:"
    send -- "$KEYPASSWORD\r"
    expect eof
EOF
)

    local address_line
    address_line=$(echo "$creation_output" | grep -oE '0x[a-fA-F0-9]{40}.*')
    
    local wallet_address returned_key_path
    read -r wallet_address returned_key_path < <(echo "$address_line")
    
    if ! [[ "$wallet_address" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        die "Failed to create wallet or parse address from output."
    fi

    echo "✅ Wallet created successfully!"
    echo "   Address: $wallet_address"
    echo "   Keyfile Path: $returned_key_path"
}

import_wallet() {
    echo "--- Import Wallet Using Private Key ---"
    read -p "Enter a name for the imported wallet: " wallet_name
    if [[ -z "$wallet_name" ]]; then
        die "Wallet name cannot be empty."
    fi
    
    read -sp "Enter private key: " private_key
    echo
    if [[ -z "$private_key" ]]; then
        die "Private key cannot be empty."
    fi

    local temp_file
    temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' EXIT
    echo "$private_key" > "$temp_file"

    local import_output
    import_output=$(expect << EOF
    set timeout 20
    spawn aut account import-private-key "$temp_file"
    expect "Password for new account:"
    send -- "$KEYPASSWORD\r"
    expect "Confirm account password:"
    send -- "$KEYPASSWORD\r"
    expect eof
EOF
)
    local generated_keyfile
    generated_keyfile=$(echo "$import_output" | grep -oE "${KEYSTORE_DIR}/UTC--[^\"]+" | tr -d '\r' | head -n 1)

    if [[ -z "$generated_keyfile" || ! -f "$generated_keyfile" ]]; then
        die "Failed to import key. Could not find the generated keyfile."
    fi
    
    local new_keyfile_path="${KEYSTORE_DIR}/${wallet_name}.key"
    mv "$generated_keyfile" "$new_keyfile_path"
    
    echo "✅ Keystore file saved to: $new_keyfile_path"
}

export_private_key() {
    echo "--- Export Private Key ---"
    local chosen_keyfile
    chosen_keyfile=$(select_keyfile)
    echo "Selected keyfile: $(basename "$chosen_keyfile")"

    local private_key
    private_key=$(ethkey inspect --private "$chosen_keyfile" <<<"$KEYPASSWORD" | awk '/Private key/ {print $3}')
    if [[ -z "$private_key" ]]; then
        die "Failed to retrieve private key. Check your password."
    fi

    local private_key_file="${KEYSTORE_DIR}/$(basename "$chosen_keyfile" .key).priv"
    echo "$private_key" >"$private_key_file"
    
    echo "✅ Private key exported successfully."
    echo "   Your Private Key: $private_key"
    echo "   Saved to: $private_key_file"
    echo "   ⚠️ WARNING: Handle this key with extreme care."
}

main() {
    check_prerequisites
    
    while true; do
        clear
        show_menu
        read -p "Enter your choice: " choice
        
        echo
        case "$choice" in
            1) create_wallet ;;
            2) import_wallet ;;
            3) export_private_key ;;
            4) bash "$TOOLS_DIR/wallet-info.sh" ;;
            5) bash "$TOOLS_DIR/signature.sh" ;;
            6) bash "$TOOLS_DIR/backup-wallet.sh" ;;
            7) bash "$TOOLS_DIR/tx.sh" ;;
            0) clear; echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
        echo
        read -n 1 -s -r -p "Press any key to continue..."
    done
}

main