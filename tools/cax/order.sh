#!/bin/bash

source $HOME/autonity/.env

get_orderbook_quote() {
    echo "Price $SELECTED_PAIR:"
    response=$(http GET "https://cax.piccadilly.autonity.org/api/orderbooks/$SELECTED_PAIR/quote" "API-Key:$APIKEY")
    echo "$response" | jq -r '. | "Bid Price: \(.bid_price)\nAsk Price: \(.ask_price)"'
}

clear

prompt_order_details() {
    read -p "Enter the side of the order (bid or ask): " SIDE
    read -p "Enter the price: " PRICE
    read -p "Enter the amount: " AMOUNT
}

submit_order() {
    if [[ -z "$APIKEY" ]]; then
        echo "API key is not set. Please set the APIKEY variable in the .env file."
        exit 1
    fi

    clear

    order_response=$(http POST "https://cax.piccadilly.autonity.org/api/orders/" "API-Key:$APIKEY" "pair=$SELECTED_PAIR" "side=$SIDE" "price=$PRICE" "amount=$AMOUNT")

    echo "Order detail:"
    if [[ -z "$order_response" ]]; then
        echo "No response received."
    else
        echo "$order_response" | jq -r '. | "Order ID: \(.order_id)\nStatus: \(.status)\nPair: \(.pair)\nSide: \(.side)\nAmount: \(.amount)\nRemain: \(.remain)"'
    fi
}

clear

echo "Select a currency pair:"
echo "1. $PAIR1"
echo "2. $PAIR2"
read -p "Enter the number of the currency pair you choose: " PAIR_NUM

case $PAIR_NUM in
    1)
        SELECTED_PAIR=$PAIR1
        ;;
    2)
        SELECTED_PAIR=$PAIR2
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

clear

get_orderbook_quote
prompt_order_details
submit_order
