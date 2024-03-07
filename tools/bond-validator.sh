#!/bin/bash

# aut Location
AUT=$(which aut)

# Load password from .env file
source ~/autonity/.env

# Retrieve ENODE from aut node info output
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
echo "ENODE retrieved: $ENODE"

# Retrieve validator identifier address from enode 
VALIDATOR_IDENTIFIER_ADDRESS=$AUT validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*'
echo "Validator identifier address retrieved: $VALIDATOR_IDENTIFIER_ADDRESS"

# get account balance from user input
read -p "Enter the amount NTN to bond: " AMOUNT
echo "Amount to bond: $AMOUNT"

# Run aut validator bond command
echo "Running aut validator bond..."
export 'KEYFILEPWD'="$KEYPASSWORD"
$AUT validator bond --validator $VALIDATOR_IDENTIFIER_ADDRESS $AMOUNT | $AUT tx sign - | $AUT tx send -
echo "bond validator completed"
