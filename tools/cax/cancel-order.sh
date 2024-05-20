#!/bin/bash

source "$HOME/autonity/.env"

API_URL="https://cax.piccadilly.autonity.org/api/orders"
API_KEY_HEADER="API-Key:$APIKEY"

get_open_order_ids() {
    http GET "$API_URL" "$API_KEY_HEADER" | jq -r '.[] | select(.status == "open") | .order_id'
}

get_order_status() {
    local order_id=$1
    http GET "$API_URL/$order_id" "$API_KEY_HEADER" 2>/dev/null | jq -r '.status'
}

cancel_order() {
    local order_id=$1
    http DELETE "$API_URL/$order_id" "$API_KEY_HEADER" >/dev/null 2>&1
}

order_ids=$(get_open_order_ids)

if [[ -n "$order_ids" ]]; then
    for order_id in $order_ids; do
        order_status=$(get_order_status "$order_id")
        if [[ "$order_status" == "open" ]]; then
            cancel_order "$order_id"
            echo "Order id $order_id canceled"
        else
            echo "Order id $order_id already canceled or closed" >&2
        fi
    done
else
    echo "No open orders found." >&2
fi
