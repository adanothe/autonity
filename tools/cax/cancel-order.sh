#!/bin/bash

source $HOME/autonity/.env

ORDERIDS=$(http GET https://cax.piccadilly.autonity.org/api/orders "API-Key:$APIKEY" | jq -r '.[] | select(.status == "open") | .order_id')
if [[ -n "$ORDERIDS" ]]; then
    for id in $ORDERIDS; do
        order_status=$(http GET https://cax.piccadilly.autonity.org/api/orders/$id "API-Key:$APIKEY" 2>/dev/null | jq -r '.status')
        if [[ "$order_status" == "open" ]]; then
            http DELETE "https://cax.piccadilly.autonity.org/api/orders/$id" "API-Key:$APIKEY" >/dev/null 2>&1
            echo "Order id $id canceled"
        else
            echo "Order id $id already canceled or closed" >&2
        fi
    done
else
    echo "No open orders found." >&2
fi
