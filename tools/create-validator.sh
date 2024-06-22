#!/bin/bash

clear

echo "autonity validator registration"
echo "-----------------------------------------------"

source ~/autonity/.env
docker=$(command -v docker)
ethkey=$(command -v ethkey)
aut=$(command -v aut)
oracle_key_file=/root/.autonity/keystore/oracle.key
treasury_key_file=/root/.autonity/keystore/treasury.key
private_key_oracle=$($ethkey inspect --private "$oracle_key_file" <<< "$KEYPASSWORD" | grep "Private key" | awk '{print $3}')
treasury_account_address=$($aut account info --keyfile "$treasury_key_file" | grep "account" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')
enode=$($aut node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
consensus_key=$($ethkey autinspect ~/autonity-chaindata/autonity/autonitykeys | grep "Consensus Public Key" | awk '{print $4}')
oracle=$($aut account info --keyfile "$oracle_key_file" | grep "account" | awk '{print $2}' | sed 's/"//g' | sed 's/,//g')

echo "generating ownership proof..."
proof=$($docker run -t -i \
    --volume $HOME/autonity-chaindata:/autonity-chaindata \
    --volume $HOME/.autonity/keystore/oracle.key:/autoracle/oracle.key \
    --name proof \
    --rm \
    ghcr.io/autonity/autonity:latest \
    genOwnershipProof \
    --autonitykeys /autonity-chaindata/autonity/autonitykeys \
    --oraclekeyhex "$private_key_oracle" \
    "$treasury_account_address")

proof=$(echo "$proof" | tr -cd '[:alnum:]')
export 'KEYFILEPWD'="$KEYPASSWORD"
tx_hash=$($aut validator register "$enode" "$oracle" "$consensus_key" "$proof" | $aut tx sign - | $aut tx send -)
validator_identifier_address=$($aut validator info | jq -r '.node_address' | tr '[:upper:]' '[:lower:]')

validator=$($aut validator list | grep "$validator_identifier_address")
if [ "$validator" = "$validator_identifier_address" ]; then
    echo "validator is registered"
else
    echo "validator is not registered"
fi

echo "transaction hash: https://piccadilly.autonity.org/tx/$tx_hash"
echo "your validator address is: $validator_identifier_address"
echo "validator= $validator_identifier_address" >> ~/.autrc
echo "to check detail validator, run: autonity validator info"

read -p "press enter to exit"
