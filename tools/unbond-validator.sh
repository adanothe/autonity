#!/bin/bash

# aut Location
AUT=$(which aut)

# Load password from .env file
source ~/autonity/.env

# Retrieve ENODE from aut node info output
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
echo "ENODE retrieved: $ENODE"

# Retrieve validator identifier address from enode 
$AUT validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*'
echo "Validator identifier address retrieved: $VALIDATOR_IDENTIFIER_ADDRESS"

# get account balance from user input
read -p "Enter the amount NTN to unbond: " AMOUNT
echo "Amount to unbond: $AMOUNT"

# Run aut validator unbond command
echo "Running unbond validator bond..."
export 'KEYFILEPWD'="$KEYPASSWORD"
$AUT validator unbond --validator $VALIDATOR_IDENTIFIER_ADDRESS $AMOUNT | $AUT tx sign - | $AUT tx send -
echo "unbond validator completed"
