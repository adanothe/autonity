#!/bin/bash

# Docker Location
DOCKER=$(which docker)
# ethkey Location
ETHKEY=$(which ethkey)

# aut Location
AUT=$(which aut)

# Oracle Key File Location
ORACLE_KEY_FILE=/root/.autonity/keystore/oracle.key

# Treasury Key File Location
TREASURY_KEY_FILE=/root/.autonity/keystore/treasury.key

# Load password from .env file
source ~/autonity/.env

# Retrieve private key from oracle key file
PRIVATE_KEY_ORACLE=$($ETHKEY inspect --private $ORACLE_KEY_FILE <<< "$KEYPASSWORD" | grep "Private key" | awk '{print $3}')
echo "Private key of oracle retrieved: $PRIVATE_KEY_ORACLE"

# Retrieve treasury account address
TREASURY_ACCOUNT_ADDRESS=$($AUT account info --keyfile $TREASURY_KEY_FILE | grep "account" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
echo "Treasury account address retrieved: $TREASURY_ACCOUNT_ADDRESS"

# Retrieve ENODE from aut node info output
ENODE=$($AUT node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
echo "ENODE retrieved: $ENODE"

# Retrieve CONSENSUS_KEY from ethkey autinspect output
CONSENSUS_KEY=$(/usr/bin/ethkey autinspect ~/autonity-chaindata/autonity/autonitykeys | grep "Consensus Public Key" | awk '{print $4}')
echo "Consensus key retrieved: $CONSENSUS_KEY"

# Retrieve ORACLE from aut account info output
ORACLE=$($AUT account info --keyfile /root/.autonity/keystore/oracle.key | grep "account" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
echo "Oracle account retrieved: $ORACLE"

# Run Docker command to register validator and send it to the blockchain
echo "Running Docker command to register validator and send it to the blockchain..."
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
echo "Ownership proof generated: $PROOF"

# Run aut validator register command with PROOF and send it to the blockchain, using passphrase from KEYPASSWORD
echo "Registering validator and sending it to the blockchain..."
export 'KEYFILEPWD'="$KEYPASSWORD"
$AUT validator register $ENODE $ORACLE $CONSENSUS_KEY $PROOF | $AUT tx sign - | $AUT tx send -
echo "Validator registered and sent to the blockchain."
