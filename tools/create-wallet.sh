#!/bin/bash

# Check package AUT
AUT=$(which aut)

# Set environment variables
source ~/autonity/.env

# Create folder keystore
KEYSTOREDIR=~/.autonity/keystore
mkdir -p $KEYSTOREDIR

# Create treasury account
expect -c "
spawn $AUT account new -k $KEYSTOREDIR/treasury.key
expect \"Password for new account:\"
send \"$KEYPASSWORD\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\r\"
expect eof
" > /dev/null 2>&1


# Create oracle account
expect -c "
spawn $AUT account new -k $KEYSTOREDIR/oracle.key
expect \"Password for new account:\"
send \"$KEYPASSWORD\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\r\"
expect eof
" > /dev/null 2>&1

# Retrieve treasury and oracle addresses
treasuryAddress=$($AUT account info -k $KEYSTOREDIR/treasury.key | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')
oracleAddress=$($AUT account info -k $KEYSTOREDIR/oracle.key | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')

# Provide treasury and oracle addresses along with their paths to the user
echo "Your treasury address and location path: $treasuryAddress $KEYSTOREDIR/treasury.key"
echo "Your oracle address and location path: $oracleAddress $KEYSTOREDIR/oracle.key"
