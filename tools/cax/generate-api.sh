#!/bin/bash

source $HOME/autonity/.env

message=$(jq -nc --arg nonce "$(date +%s%N)" '$ARGS.named')
export 'KEYFILEPWD'="$KEYPASSWORD"
aut account sign-message "$message" message.sig
apiresponse=$(echo -n "$message" | https POST "https://cax.piccadilly.autonity.org/api/apikeys" "api-sig:@message.sig")

if [[ $apiresponse == *"Unauthorized"* || $apiresponse == *"Unrecognized signature."* ]]; then
    echo "Sorry, the wallet you're using cannot create an API key or cax not deployed yet. Action not allowed."
    exit 1
fi

newapi=$(echo $apiresponse | jq -r .apikey)

if grep -q "^APIKEY=" "$HOME/autonity/.env"; then
    sed -i "s#^APIKEY=.*#APIKEY=$newapi#" "$HOME/autonity/.env"
else
    echo "apikey=$newapi" >> "$HOME/autonity/.env"
fi

echo "APIKEY added or updated in .env file"
