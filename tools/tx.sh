#!/bin/bash

AUT=$(which aut)
source $HOME/autonity/.env

echo "Autonity Currency Transfer"
echo "--------------------------"

read -p "Choose currency to send (1 for ATN, 2 for NTN): " CURRENCY
if [ "$CURRENCY" != "1" ] && [ "$CURRENCY" != "2" ]; then
    echo "Invalid currency selection"
    exit 1
fi

if [ "$CURRENCY" == "1" ]; then
    CURRENCY_NAME="ATN"
elif [ "$CURRENCY" == "2" ]; then
    CURRENCY_NAME="NTN"
fi

read -p "Enter the recipient's address: " ADDRESS
read -p "Enter the amount to send: " VALUE

export 'KEYFILEPWD'="$KEYPASSWORD"

if [ "$CURRENCY" == "1" ]; then
    TX_HASH=$($AUT tx make --to $ADDRESS --value $VALUE | $AUT tx sign - | $AUT tx send -)
else
    TX_HASH=$($AUT tx make --to $ADDRESS --value $VALUE --ntn | $AUT tx sign - | $AUT tx send -)
    echo "Transaction hash: https://piccadilly.autonity.org/tx/$TX_HASH"
fi

exit 0
