#!/bin/bash

# Define directories and file paths 
autonity_home="$HOME/autonity"
key_home="$HOME/.autonity"
keystore_dir="$key_home/keystore"
oracle_dir="$key_home/oracle"
tools_dir="$autonity_home/tools"
scripts_dir="$autonity_home/scripts"
bin_dir="$autonity_home/bin"
env_file="$autonity_home/.env"
autrc_file="$HOME/.autrc"
plugins_conf="$autonity_home/plugin/plugins-conf.yml"

# Prompt for password
echo "Enter password for wallet:"
read -s password

# Fetch the IP address of the system
your_ip=$(curl -4 ifconfig.me)

# Create the .env file with required variables
cat <<EOF > "$env_file"
KEYPASSWORD=$password
YOURIP=$your_ip
EOF

# Create necessary directories
mkdir -p "$keystore_dir" "$oracle_dir"

# Create the autrc file with RPC and keyfile configuration
cat <<EOF > "$autrc_file"
[aut]
rpc_endpoint=ws://127.0.0.1:8546
keyfile=~/.autonity/keystore/treasury.key
EOF

# Ensure executables in the tools, scripts, and bin directories are executable
chmod +x "$tools_dir"/* "$scripts_dir"/* "$bin_dir"/*

# Execute the provided shell scripts
"$scripts_dir/docker.sh"
"$scripts_dir/aut.sh"

# Copy binaries and plugins to the appropriate locations
cp "$bin_dir/"* /usr/bin/
cp "$plugins_conf" "$oracle_dir"

exit 0
