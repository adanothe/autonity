#!/bin/bash

if ! command -v aut &>/dev/null; then
    echo "Error: 'aut' command not found. Make sure it is installed and accessible in your PATH."
    exit 1
fi

source "$HOME/autonity/.env"

validator_address=$(aut validator info | jq -r '.node_address' | tr '[:upper:]' '[:lower:]')

echo "Choose an option to pause or activate the validator:"
echo "1. Activate validator"
echo "2. Pause validator"
read -p "Enter your choice: " choice

case $choice in
1)
    echo "You have chosen to activate the validator."
    action="activate"
    ;;
2)
    echo "You have chosen to pause the validator."
    action="pause"
    ;;
*)
    echo "Invalid choice, exiting."
    exit 1
    ;;
esac

echo "Running $action validator..."
export KEYFILEPWD="$KEYPASSWORD"
aut validator "$action" --validator "$validator_address" | aut tx sign - | aut tx send -
echo "$action validator completed."

echo "Please wait until the next epoch for the status to be reflected."
