#!/bin/bash

source ~/autonity/.env

AUT=$(which aut)
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
VALIDATOR_IDENTIFIER_ADDRESS=$($AUT validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*')

echo "Enter commission rate (in percentage):"
read -p "Commission rate 1-100: " RATE
echo "Commission rate: $RATE"

COMMISSION_RATE_BPS=$(awk "BEGIN { printf \"%.0f\", $RATE * 100 }")

echo "Commission rate in basis points: $COMMISSION_RATE_BPS"

export 'KEYFILEPWD'="$KEYPASSWORD"
$AUT validator change-commission-rate --validator $VALIDATOR_IDENTIFIER_ADDRESS $COMMISSION_RATE_BPS | aut tx sign - | aut tx send -
