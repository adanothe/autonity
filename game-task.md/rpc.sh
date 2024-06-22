#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Define variables
home_dir="$HOME"
autonity_dir="$home_dir/autonity"
autonity_bin="$autonity_dir/bin"
autonity_tools="$autonity_dir/tools"
autonity_keystore="$home_dir/.autonity/keystore"
keyfile="$autonity_keystore/autonitykeys.key"
private_key_file="$autonity_keystore/autonitykeys.priv"
docker_install_script="https://raw.githubusercontent.com/Dedenwrg/dependencies/main/docker/docker.sh"
go_install_script="https://raw.githubusercontent.com/Dedenwrg/dependencies/main/golang/go.sh"
message="rpc public"
rpc_port="8545"
ip=$(curl -4 ifconfig.me)
ubuntu_version=$(lsb_release -rs)

# Install Docker if not already installed
if ! command_exists docker; then
    curl -sSfL "$docker_install_script" | sudo sh
fi

# Install Go if not already installed
if ! command_exists go; then
    curl -sSfL "$go_install_script" | sudo bash
fi

# Determine Python packages based on Ubuntu version
case "$ubuntu_version" in
    20.*) python_packages="python3-pip python3.8-venv" ;;
    22.*) python_packages="python3-pip python3.10-venv" ;;
    *) echo "Unsupported Ubuntu version: $ubuntu_version"; exit 1 ;;
esac

# Install Python packages if not already installed
if ! dpkg -s $python_packages &>/dev/null; then
    sudo apt install -y $python_packages
fi

# Install pipx if not already installed
if ! command_exists pipx; then
    sudo python3 -m pip install --upgrade pipx
fi

# Install autonity CLI if not already installed
if ! command_exists aut; then
    pipx install --force git+https://github.com/autonity/aut && sudo mv "$home_dir/.local/bin/aut" /usr/local/bin/aut
fi

# Clone the autonity repository and copy binaries
git clone https://github.com/adanothe/autonity.git >/dev/null
sudo cp "$autonity_bin/ethkey" /usr/bin/ && sudo chmod +x /usr/bin/ethkey
sudo cp "$autonity_bin/autonity" /usr/bin/ && sudo chmod +x /usr/bin/autonity
chmod +x "$autonity_tools/"* "$autonity_tools/cax/"*

# Create autonity keystore directory and start autonity node
mkdir -p "$autonity_keystore"
ufw allow 8545
ufw allow ssh
ufw --force enable
autonity node start &>/dev/null

# Prompt for key password
read -p "Enter your password for key: " -s KEYPASSWORD

# Function to import a private key
import_private_key() {
    echo "$1" >"$private_key_file"
    expect -c "
    spawn aut account import-private-key $private_key_file
    expect \"Password for new account:\"
    send \"$KEYPASSWORD\r\"
    expect \"Confirm account password:\"
    send \"$KEYPASSWORD\r\"
    interact
    " >/dev/null 2>&1
}

# Check if the keyfile exists
if [ -f "$keyfile" ]; then
    signed_message=$(aut account sign-message "$message" --keyfile "$keyfile" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
    enode=$(aut node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
    echo "Signature,ENODE & rpc url for registration open the door task:"
    echo "Signature: $signed_message"
    echo "ENODE: $enode"
    echo "your rpc url: http://$ip:$rpc_port"
    exit 0
fi

# Import private key from autonitykeys file
private_key=$(head -c 64 "$home_dir/autonity-chaindata/autonity/autonitykeys")
echo "Importing private key from autonitykeys file"
import_private_key "$private_key"
mv "$autonity_keystore/UTC-"* "$keyfile"
echo "Successfully imported private key to autonitykeys.key in $keyfile"
chmod 600 "$keyfile"

# Sign message and display signature and enode
signed_message=$(aut account sign-message "$message" --keyfile "$keyfile" --password "$KEYPASSWORD" | grep -o '0x[0-9a-fA-F]*')
enode=$(aut node info | grep -o 'enode://[a-zA-Z0-9@.]*:[0-9]*')
echo "Signature,ENODE & rpc url for registration open the door task:"
echo "Signature: $signed_message"
echo "ENODE: $enode"
echo "your rpc url: http://$ip:$rpc_port"
