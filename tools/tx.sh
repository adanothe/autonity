#!/bin/bash

AUT=$(which aut)
source $HOME/autonity/.env
ORACLE=$HOME/.autonity/keystore/oracle.key
TREASURY=$HOME/.autonity/keystore/treasury.key
KEYSTORE=$HOME/.autonity/keystore

read -p "Enter the currency to send 1.ATN or 2.NTN: " CURRENCY
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
read -p "choose the key to use: 1.Oracle 2.Treasury 3.Other key: " KEY
if [ "$KEY" != "1" ] && [ "$KEY" != "2" ] && [ "$KEY" != "3" ]; then
    echo "Invalid key"
    exit 1
fi

if [ "$KEY" == "1" ]; then
    export 'KEY'="$ORACLE"
fi

if [ "$KEY" == "2" ]; then
    export 'KEY'="$TREASURY"
fi

if [ "$KEY" == "3" ]; then
    ls $KEYSTORE
    read -p "Enter the key file name: " KEYFILE
    export 'KEY'="$KEYSTORE/$KEYFILE"
fi

if [ "$CURRENCY" == "ATN" ]; then
    export 'KEYFILEPWD'="$KEYPASSWORD"
    $AUT tx make --to $ADDRESS --value $VALUE -k $KEY | $AUT tx sign - | $AUT tx send -
fi

if [ "$CURRENCY" == "NTN" ]; then
    export 'KEYFILEPWD'="$KEYPASSWORD"
    $AUT tx make --to $ADDRESS --value $VALUE --ntn $KEY | $AUT tx sign - | $AUT tx send -
fi

exit 0
