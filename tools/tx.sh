#!/bin/bash

aut=$(command -v aut)
source $HOME/autonity/.env

echo "Autonity Currency Transfer"
echo "--------------------------"

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

read -p "Enter the recipient's address: " address
read -p "Enter the amount to send: " value

export 'KEYFILEPWD'="$KEYPASSWORD"

if [ "$currency" == "1" ]; then
    tx_hash=$($aut tx make --to $address --value $value | $aut tx sign - | $aut tx send -)
else
    tx_hash=$($aut tx make --to $address --value $value --ntn | $aut tx sign - | $aut tx send -)
    echo "Transaction hash: https://piccadilly.autonity.org/tx/$tx_hash"
fi

exit 0
