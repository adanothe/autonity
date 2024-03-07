#!/bin/bash

# aut Location
AUT=$(which aut)

# Load password from .env file
source ~/autonity/.env

# Retrieve ENODE and VALIDATOR_IDENTIFIER_ADDRESS
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*') 
VALIDATOR_IDENTIFIER_ADDRESS=$AUT validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*'

# choose to bond or unbond
echo "Choose to bond or unbond" 1. Bond 2. Unbond
read -p "Enter choice: " CHOICE
echo "Choice: $CHOICE"

if [ $CHOICE -eq 1 ]
then
    echo "Bonding..."
elif [ $CHOICE -eq 2 ]
then
    echo "Unbonding..."
else
    echo "Invalid choice"
    exit 1
fi

# retrieve amount to bond or unbond
read -p "Enter amount: " AMOUNT
echo "Amount: $AMOUNT"

# Run aut validator bond command or aut validator unbond command
if [ $CHOICE -eq 1 ]
then
    echo "Running aut validator bond..."
    export 'KEYFILEPWD'="$KEYPASSWORD"
    $AUT validator bond --validator $VALIDATOR_IDENTIFIER_ADDRESS $AMOUNT | $AUT tx sign - | $AUT tx send -
    echo "bond validator completed"
elif [ $CHOICE -eq 2 ]
then
    echo "Running aut validator unbond..."
    export 'KEYFILEPWD'="$KEYPASSWORD"
    $AUT validator unbond --validator $VALIDATOR_IDENTIFIER_ADDRESS $AMOUNT | $AUT tx sign - | $AUT tx send -
    echo "unbond validator completed"
fi

exit 0
