#!/bin/bash

# aut Location
AUT=$(which aut)

# Retrieve ENODE from aut node info output
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
echo "ENODE retrieved: $ENODE" >/dev/null

# Retrieve validator identifier address from enode 
VALIDATOR_IDENTIFIER_ADDRESS=$($AUT validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*')
echo "Validator identifier address retrieved: $VALIDATOR_IDENTIFIER_ADDRESS" >/dev/null

# option chosen to pause or activate validator
echo "Choose an option to pause or activate the validator"
echo "1. activate validator"
echo "2. pause validator"
read -p "Enter your choice: " choice
if [ $choice -eq 1 ]
then
    echo "You have chosen to activate the validator"
elif [ $choice -eq 2 ]
then
    echo "You have chosen to pause the validator"
else
    echo "Invalid choice"
fi

# Run aut activate or pause validator command
if [ $choice -eq 1 ]
then
    # Run aut activate validator command
    echo "Running activate validator..."
    export 'KEYFILEPWD'="$KEYPASSWORD"
    $AUT validator activate --validator $VALIDATOR_IDENTIFIER_ADDRESS | $AUT tx sign - | $AUT tx send -
    echo "activate validator completed"
else
    # Run aut pause validator command
    echo "Running pause validator..."
    export 'KEYFILEPWD'="$KEYPASSWORD"
    $AUT validator pause --validator $VALIDATOR_IDENTIFIER_ADDRESS | $AUT tx sign - | $AUT tx send -
    echo "pause validator completed"
fi

# Retrieve validator status
STATE=$($AUT validator info --validator $VALIDATOR_IDENTIFIER_ADDRESS | jq -r '.state')

# Check the state
if [ "$STATE" -eq 0 ]; then
    echo "Validator is activated"
elif [ "$STATE" -eq 1 ]; then
    echo "Validator is paused"
elif [ "$STATE" -eq 2 ]; then
    echo "Validator is jailed"
else
    echo "Unknown state"
fi

