#!/bin/bash

source $HOME/autonity/.env

echo "Autonity Wallet Transfer"
echo "--------------------------"

choose_wallet() {
    wallets=()
    addresses=()
    IFS=$'\n'
    for line in $(autonity wallet info); do
        if [[ $line == *"wallet"* ]]; then
            wallets+=("$line")
        elif [[ $line == "Address      :"* ]]; then
            addresses+=("${line##*: }")
        fi
    done

    echo "Available Wallets:"
    for i in "${!wallets[@]}"; do
        echo "$((i + 1)). ${wallets[$i]}"
    done

    read -p "Choose a wallet (1-${#wallets[@]}): " wallet_choice
    if [[ $wallet_choice -lt 1 || $wallet_choice -gt ${#wallets[@]} ]]; then
        echo "Invalid choice"
        exit 1
    fi

    chosen_address="${addresses[$((wallet_choice - 1))]}"
    echo "Selected address: $chosen_address"
    echo ""
}

read -p "Choose currency to send (1 for ATN, 2 for NTN): " currency
if [ "$currency" != "1" ] && [ "$currency" != "2" ]; then
    echo "Invalid currency selection"
    exit 1
fi

if [ "$currency" == "1" ]; then
    currency_name="ATN"
elif [ "$currency" == "2" ]; then
    currency_name="NTN"
fi

read -p "Do you want to choose wallet from the list or enter address manually? (1 for list, 2 for manual): " address_choice
if [ "$address_choice" == "1" ]; then
    choose_wallet
else
    read -p "Enter the recipient's address: " chosen_address
fi

read -p "Enter the amount to send: " value

export 'KEYFILEPWD'="$KEYPASSWORD"

if [ "$currency" == "1" ]; then
    tx_hash=$(aut tx make --to $chosen_address --value $value | aut tx sign - | aut tx send -)
elif [ "$currency" == "2" ]; then
    tx_hash=$(aut tx make --to $chosen_address --value $value --ntn | aut tx sign - | aut tx send -)
fi

echo "Transaction hash: https://piccadilly.autonity.org/tx/$tx_hash"

exit 0
