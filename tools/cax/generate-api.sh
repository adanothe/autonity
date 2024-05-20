#!/bin/bash

source $HOME/autonity/.env

MESSAGE=$(jq -nc --arg nonce "$(date +%s%N)" '$ARGS.named')
export 'KEYFILEPWD'="$KEYPASSWORD"
aut account sign-message "$MESSAGE" message.sig
APIRESPONSE=$(echo -n "$MESSAGE" | https POST "https://cax.piccadilly.autonity.org/api/apikeys" "api-sig:@message.sig")

if [[ $APIRESPONSE == *"Unauthorized"* && $APIRESPONSE == *"Unrecognized signature."* ]]; then
    echo "Sorry, the wallet you're using cannot create an API key. Action not allowed."
    exit 1
fi

NEWAPI=$(echo $APIRESPONSE | jq -r .apikey)

if grep -q "^APIKEY=" "$HOME/autonity/.env"; then
    sed -i "s#^APIKEY=.*#APIKEY=$NEWAPI#" "$HOME/autonity/.env"
else
    echo "APIKEY=$NEWAPI" >> "$HOME/autonity/.env"
fi

echo "APIKEY added or updated in .env file"
