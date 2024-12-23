#!/bin/bash

source ~/autonity/.env
ethkey=$(command -v ethkey)
keystore_dir="$HOME/.autonity/keystore"
echo "Autonity wallet import"
echo "--------------------------"

keyfiles=($(ls $keystore_dir | grep '\.key$'))
echo "Available wallet:"
for i in "${!keyfiles[@]}"; do
    echo "$((i + 1)). ${keyfiles[$i]}"
done

read -p "Choose wallet to import (1-${#keyfiles[@]}): " keyfile_choice
if [[ $keyfile_choice -lt 1 || $keyfile_choice -gt ${#keyfiles[@]} ]]; then
    echo "Invalid choice"
    exit 1
fi

chosen_keyfile="${keyfiles[$((keyfile_choice - 1))]}"
echo "Selected keyfile: $chosen_keyfile" >/dev/null 2>&1
echo ""

private_key=$($ethkey inspect --private "$keystore_dir/$chosen_keyfile" <<<"$KEYPASSWORD" | grep "Private key" | awk '{print $3}')
echo "Private key for $chosen_keyfile: $private_key"
