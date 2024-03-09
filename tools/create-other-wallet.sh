#!/bin/bash

# Check package AUT
AUT=$(which aut)

# Set environment variables
source ~/autonity/.env

# Create folder keystore
KEYSTOREDIR=~/.autonity/keystore

# Create wallet name
read -p "Enter the name of your wallet: " NAMEWALLET

# Create wallet
expect -c "
spawn $AUT account new -k $KEYSTOREDIR/$NAMEWALLET.key
expect \"Password for new account:\"
send \"$KEYPASSWORD\r\"
expect \"Confirm account password:\"
send \"$KEYPASSWORD\r\"
expect eof
" > /dev/null 2>&1


# Retrieve wallet address
walletAddress=$($AUT account info -k $KEYSTOREDIR/$NAMEWALLET.key | grep -o '"account": *"[^"]*"' | awk -F'"' '{print $4}')

# Provide wallet address and location path
echo "Your wallet address and location path: $walletAddress $KEYSTOREDIR/$NAMEWALLET.key"
