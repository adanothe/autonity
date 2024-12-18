#!/bin/bash

source "$HOME/autonity/.env"

validator_address=$(aut validator info | jq -r '.node_address')

bond_validator() {
    read -p "Enter amount to bond: " amount
    echo "Bonding $amount tokens to the validator..."
    export KEYFILEPWD="$KEYPASSWORD"
    tx_hash=$(aut validator bond --validator "$validator_address" "$amount" | aut tx sign - | aut tx send -)
    echo "Bonding process completed"
    echo "Transaction hash: https://piccadilly.autonity.org/tx/$tx_hash"
}

unbond_validator() {
    read -p "Enter amount to unbond: " amount
    echo "Unbonding $amount tokens from the validator..."
    export KEYFILEPWD="$KEYPASSWORD"
    tx_hash=$(aut validator unbond --validator "$validator_address" "$amount" | aut tx sign - | aut tx send -)
    echo "Unbonding process completed"
    echo "Transaction hash: https://piccadilly.autonity.org/tx/$tx_hash"
}

echo "Choose an action:"
echo "1. Bond"
echo "2. Unbond"
read -p "Enter your choice: " choice

case $choice in
1)
    bond_validator
    ;;
2)
    unbond_validator
    ;;
*)
    echo "Invalid choice"
    exit 1
    ;;
esac

exit 0
