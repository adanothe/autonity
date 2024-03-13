#!/bin/bash

AUT=$(which aut)

source ~/autonity/.env

ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
VALIDATOR_IDENTIFIER_ADDRESS=$($AUT validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*')

bond_validator() {
    read -p "Enter amount to bond: " AMOUNT
    echo "Bonding $AMOUNT tokens to the validator..."
    export 'KEYFILEPWD'="$KEYPASSWORD"
    TX_HASH=$($AUT validator bond --validator $VALIDATOR_IDENTIFIER_ADDRESS $AMOUNT | $AUT tx sign - | $AUT tx send -)
    echo "Bonding process completed"
    echo "Transaction hash: https://piccadilly.autonity.org/tx/$TX_HASH"
}

unbond_validator() {
    read -p "Enter amount to unbond: " AMOUNT
    echo "Unbonding $AMOUNT tokens from the validator..."
    export 'KEYFILEPWD'="$KEYPASSWORD"
    TX_HASH=$($AUT validator unbond --validator $VALIDATOR_IDENTIFIER_ADDRESS $AMOUNT | $AUT tx sign - | $AUT tx send -)
    echo "Unbonding process completed"
    echo "Transaction hash: https://piccadilly.autonity.org/tx/$TX_HASH"
}

echo "Choose an action:"
echo "1. Bond"
echo "2. Unbond"
read -p "Enter your choice: " CHOICE

case $CHOICE in
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