#!/bin/bash

source ~/autonity/.env
AUT=$(which aut)
KEYSTOREDIR=~/.autonity/keystore
RPC=https://rpc1.piccadilly.autonity.org/
mkdir -p $KEYSTOREDIR


expect -c "
spawn $AUT account new -k $KEYSTOREDIR/treasury.key
expect \"Password for new account:\"
send \"$KEYPASSWORD\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\r\"
expect eof
" > /dev/null 2>&1

expect -c "
spawn $AUT account new -k $KEYSTOREDIR/oracle.key
expect \"Password for new account:\"
send \"$KEYPASSWORD\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\r\"
expect eof
" > /dev/null 2>&1

treasuryAddress=$($AUT account info -r $RPC -k $KEYSTOREDIR/treasury.key | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')
oracleAddress=$($AUT account info -r $RPC -k $KEYSTOREDIR/oracle.key | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')
echo "Your treasury address and location path: $treasuryAddress $KEYSTOREDIR/treasury.key"
echo "Your oracle address and location path: $oracleAddress $KEYSTOREDIR/oracle.key"
