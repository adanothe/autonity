#!/bin/bash

# detect path package
DOCKER=$(which docker)
ETHKEY=$(which ethkey)
AUT=$(which aut)

# Load password from .env file
source ~/autonity/.env

# location oracle.key and treasury.key 
ORACLE_KEY_FILE=/root/.autonity/keystore/oracle.key
TREASURY_KEY_FILE=/root/.autonity/keystore/treasury.key

# Get private key from oracle, get treasury account address, get enode, get consensus key, get oracle address 
PRIVATE_KEY_ORACLE=$($ETHKEY inspect --private $ORACLE_KEY_FILE <<< "$KEYPASSWORD" | grep "Private key" | awk '{print $3}')
TREASURY_ACCOUNT_ADDRESS=$($AUT account info --keyfile $TREASURY_KEY_FILE | grep "account" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
CONSENSUS_KEY=$($ETHKEY autinspect ~/autonity-chaindata/autonity/autonitykeys | grep "Consensus Public Key" | awk '{print $4}')
ORACLE=$($AUT account info --keyfile /root/.autonity/keystore/oracle.key | grep "account" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')

# Run Docker command to register validator and send it to the blockchain
PROOF=$($DOCKER run -t -i \
    --volume $HOME/autonity-chaindata:/autonity-chaindata \
    --volume $HOME/.autonity/keystore/oracle.key:/autoracle/oracle.key \
    --name proof \
    --rm \
    ghcr.io/autonity/autonity:latest \
    genOwnershipProof \
    --autonitykeys /autonity-chaindata/autonity/autonitykeys \
    --oraclekeyhex $PRIVATE_KEY_ORACLE \
    $TREASURY_ACCOUNT_ADDRESS)

# Remove all non-alphanumeric characters from PROOF
PROOF=$(echo "$PROOF" | tr -cd '[:alnum:]')

# Run aut validator register command with PROOF and send it to the blockchain, using passphrase from KEYPASSWORD
export 'KEYFILEPWD'="$KEYPASSWORD"
$AUT validator register $ENODE $ORACLE $CONSENSUS_KEY $PROOF | $AUT tx sign - | $AUT tx send -

# check validator address
VALIDATOR_IDENTIFIER_ADDRESS=$($AUT validator compute-address $ENODE | grep -o '0x[a-zA-Z0-9]*')

# check if validator is registered
VALIDATOR=$($AUT validator list | grep $VALIDATOR_IDENTIFIER_ADDRESS)
if [ "$VALIDATOR=$VALIDATOR_IDENTIFIER_ADDRESS" ]; then
    echo "Validator is registered"
else
    echo "Validator is not registered"
fi

echo "your validator address is: $VALIDATOR_IDENTIFIER_ADDRESS"

# save validator address to .autrc file
echo "validator= $VALIDATOR_IDENTIFIER_ADDRESS" >> ~/.autrc
echo "to check detail validator, run: autonity validator info"
