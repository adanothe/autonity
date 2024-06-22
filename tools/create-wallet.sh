#!/bin/bash

source ~/autonity/.env
aut=$(which aut)
keystoredir=~/.autonity/keystore
rpc=https://rpc1.piccadilly.autonity.org/
mkdir -p $keystoredir


expect -c "
spawn $aut account new -k $keystoredir/treasury.key
expect \"Password for new account:\"
send \"$KEYPASSWORD\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\r\"
expect eof
" > /dev/null 2>&1

expect -c "
spawn $aut account new -k $keystoredir/oracle.key
expect \"Password for new account:\"
send \"$KEYPASSWORD\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\r\"
expect eof
" > /dev/null 2>&1

treasuryaddress=$($aut account info -r $rpc -k $keystoredir/treasury.key | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')
oracleaddress=$($aut account info -r $rpc -k $keystoredir/oracle.key | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')
echo "Your treasury address and location path: $treasuryaddress $keystoredir/treasury.key"
echo "Your oracle address and location path: $oracleaddress $keystoredir/oracle.key"
