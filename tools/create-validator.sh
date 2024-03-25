  GNU nano 6.2                                                                           dpx.sh                                                                                     
#!/bin/bash

clear

echo "Autonity Validator Registration"
echo "-----------------------------------------------"

DOCKER=$(which docker)
ETHKEY=$(which ethkey)
AUT=$(which aut)

source ~/autonity/.env

ORACLE_KEY_FILE=/root/.autonity/keystore/oracle.key
TREASURY_KEY_FILE=/root/.autonity/keystore/treasury.key

PRIVATE_KEY_ORACLE=$($ETHKEY inspect --private "$ORACLE_KEY_FILE" <<< "$KEYPASSWORD" | grep "Private key" | awk '{print $3}')
TREASURY_ACCOUNT_ADDRESS=$($AUT account info --keyfile "$TREASURY_KEY_FILE" | grep "account" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
CONSENSUS_KEY=$($ETHKEY autinspect ~/autonity-chaindata/autonity/autonitykeys | grep "Consensus Public Key" | awk '{print $4}')
ORACLE=$($AUT account info --keyfile "$ORACLE_KEY_FILE" | grep "account" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')

echo "Generating ownership proof..."
PROOF=$($DOCKER run -t -i \
    --volume $HOME/autonity-chaindata:/autonity-chaindata \
    --volume $HOME/.autonity/keystore/oracle.key:/autoracle/oracle.key \
    --name proof \
    --rm \
    ghcr.io/autonity/autonity:latest \
    genOwnershipProof \
    --autonitykeys /autonity-chaindata/autonity/autonitykeys \
    --oraclekeyhex "$PRIVATE_KEY_ORACLE" \
    "$TREASURY_ACCOUNT_ADDRESS")

PROOF=$(echo "$PROOF" | tr -cd '[:alnum:]')

export 'KEYFILEPWD'="$KEYPASSWORD"
TX_HASH=$($AUT validator register "$ENODE" "$ORACLE" "$CONSENSUS_KEY" "$PROOF" | $AUT tx sign - | $AUT tx send -)

VALIDATOR_IDENTIFIER_ADDRESS=$($AUT validator compute-address "$ENODE" | grep -o '0x[a-zA-Z0-9]*')

VALIDATOR=$($AUT validator list | grep "$VALIDATOR_IDENTIFIER_ADDRESS")
if [ "$VALIDATOR" = "$VALIDATOR_IDENTIFIER_ADDRESS" ]; then
    echo "Validator is registered"
else
    echo "Validator is not registered"
fi

echo "Transaction hash: https://piccadilly.autonity.org/tx/$TX_HASH"
echo "Your validator address is: $VALIDATOR_IDENTIFIER_ADDRESS"
echo "validator= $VALIDATOR_IDENTIFIER_ADDRESS" >> ~/.autrc
echo "to check detail validator, run: autonity validator info"
