#!/bin/bash

source $HOME/autonity/.env

withdraw() {
    if [[ -z "$APIKEY" ]]; then
        echo "Error: API key is not set. Please set the APIKEY variable in the .env file."
        exit 1
    fi

    response=$(http POST "https://cax.piccadilly.autonity.org/api/withdraws/" "API-Key:$APIKEY" "symbol=$CURRENCY" "amount=$AMOUNT")

    if [[ -n "$response" ]]; then
        echo "Withdrawal request submitted successfully."
        echo "$response"
    else
        echo "Failed to submit withdrawal request. Please try again later."
    fi
}

clear

echo "Welcome to CAX Withdrawal"
echo "--------------------------"

echo "Select the currency to withdraw:"
echo "1. ATN"
echo "2. NTN"
read -p "Enter the number of the currency you want to withdraw: " CHOICE

case $CHOICE in
    1)
        CURRENCY="ATN"
        ;;
    2)
        CURRENCY="NTN"
        ;;
    *)
        echo "Invalid choice. Please choose 1 or 2."
        exit 1
        ;;
esac

read -p "Enter the amount to withdraw: " AMOUNT

withdraw
