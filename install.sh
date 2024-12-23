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
plugins_conf="$autonity_home/plugins/plugins-conf.yml"

if [[ -f "$autonity_home/.env.example" ]]; then
    cp "$autonity_home/.env.example" "$env_file"
else
    echo "Error: .env.example not found in $autonity_home"
    exit 1
fi

echo "Enter password for wallet:"
read -s password

if your_ip=$(curl -4 -s ifconfig.me); then
    echo "Fetched IP: $your_ip"
else
    echo "Error: Unable to fetch IP address."
    exit 1
fi

sed -i "s/^KEYPASSWORD=.*/KEYPASSWORD=$password/" "$env_file"
sed -i "s/^YOURIP=.*/YOURIP=$your_ip/" "$env_file"
echo "RPC_URL=ws://127.0.0.1:8546" >> "$env_file"


mkdir -p "$keystore_dir" "$oracle_dir"

cat <<EOF > "$autrc_file"
[aut]
rpc_endpoint=ws://127.0.0.1:8546
keyfile=~/.autonity/keystore/treasury.key
EOF

for dir in "$tools_dir" "$scripts_dir" "$bin_dir"; do
    if [[ -d "$dir" ]]; then
        chmod +x "$dir"/*
    else
        echo "Warning: Directory $dir not found or empty."
    fi
done

if [[ -x "$scripts_dir/docker.sh" && -x "$scripts_dir/aut.sh" && -x "$scripts_dir/package.sh" ]]; then
    "$scripts_dir/docker.sh"
    "$scripts_dir/aut.sh"
    "$scripts_dir/package.sh"
else
    echo "Error: One or more required scripts not found or not executable."
    exit 1
fi

cp "$bin_dir/"* /usr/bin/ 2>/dev/null || echo "No binaries to copy."
cp "$plugins_conf" "$oracle_dir" 2>/dev/null || echo "No plugins-conf.yml to copy."

exit 0
