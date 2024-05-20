#!/bin/bash

source ~/autonity/.env

AUT=$(command -v aut)
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
VALIDATOR_IDENTIFIER_ADDRESS=$($AUT validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*')

bond_validator() {
    read -p "Enter amount to bond: " amount
    echo "Bonding $amount tokens to the validator..."
    export KEYFILEPWD="$KEYPASSWORD"
    tx_hash=$($AUT validator bond --validator $VALIDATOR_IDENTIFIER_ADDRESS $amount | $AUT tx sign - | $AUT tx send -)
    echo "Bonding process completed"
    echo "Transaction hash: https://piccadilly.autonity.org/tx/$tx_hash"
}

unbond_validator() {
    read -p "Enter amount to unbond: " amount
    echo "Unbonding $amount tokens from the validator..."
    export KEYFILEPWD="$KEYPASSWORD"
    tx_hash=$($AUT validator unbond --validator $VALIDATOR_IDENTIFIER_ADDRESS $amount | $AUT tx sign - | $AUT tx send -)
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
