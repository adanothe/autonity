#!/bin/bash

clear

echo "Autonity Validator Registration"
echo "-----------------------------------------------"

ENV_FILE="$HOME/autonity/.env"
AUTRC_FILE="$HOME/.autrc"
AUTONITY_KEYS="$HOME/autonity-chaindata/autonity/autonitykeys"
TREASURY_KEY="$HOME/.autonity/keystore/treasury.key"
ORACLE_KEY="$HOME/.autonity/keystore/oracle.key"
DOCKER_IMAGE="ghcr.io/autonity/autonity:latest"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "Error: env file not found at $ENV_FILE"
    exit 1
fi

if [ -z "$KEYPASSWORD" ]; then
    echo "Error: KEYPASSWORD not found in $ENV_FILE"
    exit 1
fi
export KEYFILEPWD="$KEYPASSWORD"

TREASURY_ACCOUNT_ADDRESS=$(aut account info --keyfile "$TREASURY_KEY" | jq -r '.[0].account')
ENODE=$(aut node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
CONSENSUS_KEY=$(ethkey autinspect "$AUTONITY_KEYS" | awk '/Consensus Public Key/ {print $4}')
ORACLE_ADDRESS=$(aut account info --keyfile "$ORACLE_KEY" | jq -r '.[0].account')

echo "Generating ownership proof..."
PROOF=$(docker run -t -i \
    --volume "$HOME/autonity-chaindata:/autonity-chaindata" \
    --volume "$HOME/.autonity/keystore/oracle.priv:/autoracle/oracle.key" \
    --name proof \
    --rm \
    $DOCKER_IMAGE \
    genOwnershipProof \
    --autonitykeys /autonity-chaindata/autonity/autonitykeys \
    --oraclekey /autoracle/oracle.key \
    "$TREASURY_ACCOUNT_ADDRESS")
PROOF=$(echo "$PROOF" | tr -cd '[:alnum:]')

TX_HASH=$(aut validator register "$ENODE" "$ORACLE_ADDRESS" "$CONSENSUS_KEY" "$PROOF" | aut tx sign - | aut tx send -)
VALIDATOR_ADDRESS=$(aut validator compute-address "$ENODE")
VALIDATOR=$(aut validator list | grep "$VALIDATOR_ADDRESS")

if sed -i "s|^validator=.*|validator=$VALIDATOR_ADDRESS|" "$AUTRC_FILE"; then
    if ! grep -q "^validator=" "$AUTRC_FILE"; then
        echo "validator=$VALIDATOR_ADDRESS" >> "$AUTRC_FILE"
    fi
fi

if [ "$VALIDATOR" == "$VALIDATOR_ADDRESS" ]; then
    echo "Validator registered successfully."
else
    echo "Validator registration failed."
fi

echo "Transaction hash: https://piccadilly.autonity.org/tx/$TX_HASH"
echo "Your validator address is: $VALIDATOR_ADDRESS"
echo "To check validator details, run: autonity validator info"

read -p "Press Enter to exit."
