#!/bin/bash

TOOLS="$HOME/autonity/tools"
env_file="$HOME/autonity/.env"
keystore_dir="$HOME/.autonity/keystore"
temp_file="$PWD/${wallet_name}.priv"
rpc_url="https://picadilly.autonity-apis.com"

if [ -f "$env_file" ]; then
    source "$env_file"
else
    echo "Error: .env file not found in $HOME/autonity."
    exit 1
fi

ethkey=$(command -v ethkey)
if [ -z "$ethkey" ]; then
    echo "Error: 'ethkey' command not found."
    exit 1
fi

if [ ! -d "$keystore_dir" ]; then
    echo "Error: Keystore directory not found in $keystore_dir."
    exit 1
fi

while true; do
    clear
    cat <<EOF
===== Wallet Menu =====
1. Create new wallet
2. Import wallet using private key
3. Export private key from existing wallet
4. wallet list
5. create signature message
6. create signature message for validator
7. backup wallet
8. create transaction
0. Exit
=====================================
EOF
    read -p "Enter your choice (0-5): " choice

    case $choice in
        1)
            echo "Autonity Wallet - Create New Wallet"
            echo "-----------------------------------"

            mkdir -p "$keystore_dir"
            read -p "Enter the name for the new wallet: " wallet_name
            expect -c "
            spawn aut account new -k $keystore_dir/$wallet_name.key
            expect \"Password for new account:\"
            send \"$KEYPASSWORD\r\"
            expect \"Confirm account password:\"
            send \"$KEYPASSWORD\r\"
            expect eof
            " >/dev/null 2>&1

            if [ ! -f "$keystore_dir/$wallet_name.key" ]; then
                echo "Error: Failed to create wallet."
                exit 1
            fi

            wallet_address=$(aut account info -r "$rpc_url" -k "$keystore_dir/$wallet_name.key" | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')
            echo "Your wallet has been created successfully!"
            echo "address: $wallet_address"
            echo "Wallet keyfile path: $keystore_dir/$wallet_name.key"
            ;;

        2)
            echo "Autonity Wallet - Import Wallet Using Private Key"
            echo "-------------------------------------------------"

            read -p "Enter wallet name: " wallet_name
            read -sp "Enter private key: " private_key
            echo

            if [ -z "$private_key" ]; then
                echo "Error: Private key cannot be empty."
                exit 1
            fi

            echo "$private_key" >"$temp_file"

            import_output=$(expect -c "
            spawn aut account import-private-key \"$temp_file\"
            expect \"Password for new account:\"
            send \"$KEYPASSWORD\r\"
            expect \"Confirm account password:\"
            send \"$KEYPASSWORD\r\"
            expect eof
            " 2>&1)

            keystore_file=$(echo "$import_output" | grep -o "$keystore_dir/UTC--[^\"]*" | head -n 1)
            keystore_file=$(echo "$keystore_file" | tr -d '\r')
            new_keystore_file="$HOME/.autonity/keystore/${wallet_name}.key"
            mv "$keystore_file" "$new_keystore_file"

            echo "Keystore file saved to: $new_keystore_file"
            rm "$temp_file"
            ;;

        3)
            echo "Autonity Wallet - Export Private Key"
            echo "--------------------------------------"

            keyfiles=($(find "$keystore_dir" -type f -name '*.key'))
            if [ ${#keyfiles[@]} -eq 0 ]; then
                echo "No wallet files found in $keystore_dir."
                exit 1
            fi

            echo "Available wallets:"
            for i in "${!keyfiles[@]}"; do
                echo "$((i + 1)). $(basename "${keyfiles[$i]}")"
            done

            read -p "Choose a wallet to retrieve the private key (1-${#keyfiles[@]}): " keyfile_choice

            if [[ ! $keyfile_choice =~ ^[0-9]+$ ]] || [ "$keyfile_choice" -lt 1 ] || [ "$keyfile_choice" -gt "${#keyfiles[@]}" ]; then
                echo "Invalid choice."
                exit 1
            fi

            chosen_keyfile="${keyfiles[$((keyfile_choice - 1))]}"
            echo "Selected keyfile: $(basename "$chosen_keyfile")"

            if [ -z "$KEYPASSWORD" ]; then
                echo "Error: KEYPASSWORD not set in .env file."
                exit 1
            fi

            private_key=$($ethkey inspect --private "$chosen_keyfile" <<<"$KEYPASSWORD" 2>/dev/null | grep "Private key" | awk '{print $3}')
            if [ -z "$private_key" ]; then
                echo "Error: Failed to retrieve private key."
                exit 1
            fi

            echo "Private key for $(basename "$chosen_keyfile"): $private_key"

            private_key_file="$keystore_dir/$(basename "$chosen_keyfile" .key).priv"
            echo "$private_key" >"$private_key_file"
            echo "your private key is: $private_key"
            echo "Private key saved to $private_key_file"
            ;;

        4)
            bash "$TOOLS/wallet-info.sh"
            ;;

        5)
            bash "$TOOLS/signature.sh"
            ;;

        6) 
            bash "$TOOLS/validator-signature.sh"
            ;;

        7)
            bash "$TOOLS/backup-wallet.sh"
            ;;

        8)
            bash "$TOOLS/tx.sh"
            ;;

        0)
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo "Invalid choice. Please enter a number between 0 and 5."
            ;;
    esac

    read -p "Press Enter to continue..."
    clear
done
