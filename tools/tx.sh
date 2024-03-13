#!/bin/bash

AUT=$(which aut)
source $HOME/autonity/.env

read -p "choose currency to send 1. ATN or 2. NTN : " CURRENCY
if [ "$CURRENCY" != "1" ] && [ "$CURRENCY" != "2" ]; then
    echo "Invalid currency"
    exit 1
fi

if [ "$CURRENCY" == "1" ]; then
    export 'CURRENCY'="ATN"
fi

if [ "$CURRENCY" == "2" ]; then
    export 'CURRENCY'="NTN"
fi

read -p "Enter the address to send to: " ADDRESS
read -p "Enter the value to send: " VALUE

if [ "$CURRENCY" == "ATN" ]; then
    export 'KEYFILEPWD'="$KEYPASSWORD"
    $AUT tx make --to $ADDRESS --value $VALUE | $AUT tx sign - | $AUT tx send -
fi

if [ "$CURRENCY" == "NTN" ]; then
    export 'KEYFILEPWD'="$KEYPASSWORD"
    $AUT tx make --to $ADDRESS --value $VALUE --ntn | $AUT tx sign - | $AUT tx send -
fi

exit 0
