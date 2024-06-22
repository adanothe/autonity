#!/bin/bash

if ! command -v aut &> /dev/null; then
    echo "error: 'aut' command not found. make sure it is installed and accessible in your path."
    exit 1
fi

source ~/autonity/.env
aut=$(command -v aut)
validator_address=$($aut validator info | jq -r '.node_address' | tr '[:upper:]' '[:lower:]')

echo "choose an option to pause or activate the validator:"
echo "1. activate validator"
echo "2. pause validator"
read -p "enter your choice: " choice

case $choice in
    1)
        echo "you have chosen to activate the validator"
        action="activate"
        ;;
    2)
        echo "you have chosen to pause the validator"
        action="pause"
        ;;
    *)
        echo "invalid choice, exiting."
        exit 1
        ;;
esac

echo "running $action validator..."
export 'KEYFILEPWD'="$KEYPASSWORD"
"$aut" validator $action --validator $validator_address | "$aut" tx sign - | "$aut" tx send -
echo "$action validator completed"

state=$("$aut" validator info --validator $validator_address | jq -r '.state')

case $state in
    0) echo "validator is activated";;
    1) echo "validator is paused";;
    2) echo "validator is jailed";;
    *) echo "unknown state";;
esac
