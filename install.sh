#!/bin/bash

# Define directories and file paths as variables for better readability
AUTONITY_HOME="$HOME/autonity"
KEY_HOME="$HOME/.autonity"
KESTORE_DIR="$KEY_HOME/keystore"
ORACLE_DIR="$KEY_HOME/oracle"
TOOLS_DIR="$AUTONITY_HOME/tools"
SCRIPTS_DIR="$AUTONITY_HOME/scripts"
BIN_DIR="$AUTONITY_HOME/bin"
ENV_FILE="$AUTONITY_HOME/.env"
AUTRC_FILE="$HOME/.autrc"
PLUGINS_CONF="$AUTONITY_HOME/plugins/plugins-conf.yml"

echo "Enter password:"
read -s PASSWORD

YOUR_IP=$(curl -4 ifconfig.me)

cat <<EOF > "$ENV_FILE"
KEYPASSWORD=$PASSWORD
YOURIP=$YOUR_IP
EOF

mkdir -p "$KESTORE_DIR"
mkdir -p "$ORACLE_DIR"

cat <<EOF > "$AUTRC_FILE"
[aut]
rpc_endpoint=ws://127.0.0.1:8546
keyfile=~/.autonity/keystore/treasury.key
EOF

chmod +x "$TOOLS_DIR"/*
chmod +x "$SCRIPTS_DIR"/*
chmod +x "$BIN_DIR"/*

"$SCRIPTS_DIR/docker.sh"
"$SCRIPTS_DIR/aut.sh"

cp "$BIN_DIR/ethkey" /usr/bin/
cp "$BIN_DIR/autonity" /usr/bin/

cp "$PLUGINS_CONF" "$ORACLE_DIR"

exit 0
