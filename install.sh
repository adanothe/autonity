#!/bin/bash

# Function to log command execution with timestamp
log_command() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)

# Create a folder for Autonity
log_command "Creating folder for Autonity"
mkdir -p $HOME/.autonity/oracle 

# Check if Docker is already installed
if ! command -v docker &> /dev/null; then
    # Install Docker
    log_command "Installing Docker"
    curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/Dedenwrg/dependencies/main/docker/docker.sh | sudo sh
fi

# Check if Go is already installed
if ! command -v go &> /dev/null; then
    # Install Go
    log_command "Installing Go"
    curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/Dedenwrg/dependencies/main/golang/go.sh | sudo bash
fi

# Install AUT dependencies if not already installed
if [[ $UBUNTU_VERSION == "20."* ]]; then
    if ! dpkg -s python3-pip python3.8-venv &> /dev/null; then
        log_command "Installing Python dependencies"
        sudo apt install python3-pip python3.8-venv -y
    else
        log_command "Python dependencies already installed"
    fi
elif [[ $UBUNTU_VERSION == "22."* ]]; then
    if ! dpkg -s python3-pip python3.10-venv &> /dev/null; then
        log_command "Installing Python dependencies"
        sudo apt install python3-pip python3.10-venv -y
    else
        log_command "Python dependencies already installed"
    fi
else
    log_command "Unsupported Ubuntu version"
    exit 1
fi

# Install pipx if not already installed
if ! command -v pipx &> /dev/null; then
    log_command "Installing pipx"
    sudo python3 -m pip install --upgrade pipx
else
    log_command "pipx already installed"
fi

# Check if AUT is already installed
if ! command -v aut &> /dev/null; then
    # Install AUT
    log_command "Installing AUT"
    pipx install --force git+https://github.com/autonity/aut && sudo mv $HOME/.local/bin/aut /usr/local/bin/aut
else
    log_command "AUT already installed"
fi

# Clone tools repository
log_command "Cloning tools repository"
git clone https://github.com/adanothe/autonity.git
cd autonity

# Export KEYPASSWORD and YOURIP to .env file
read -p "Enter your KEYPASSWORD: " KEYPASSWORD
echo "KEYPASSWORD=$KEYPASSWORD" > $HOME/autonity/.env
echo "YOURIP=$(curl -4 ifconfig.me)" >> $HOME/autonity/.env

# Move ethkey
log_command "Moving ethkey"
sudo cp $HOME/autonity/bin/ethkey /usr/bin/ && sudo chmod +x /usr/bin/ethkey

# Move plugins-conf.yml
log_command "Moving plugins-conf.yml"
cp $HOME/autonity/plugins/plugins-conf.yml $HOME/.autonity/oracle

# Change execution permission for scripts inside autonity/tools
log_command "Changing execution permission for scripts"
chmod +x $HOME/autonity/tools/*

# Create wallet
log_command "Creating wallet"
$HOME/autonity/tools/create-wallet.sh
echo "your wallet password is $KEYPASSWORD"
sleep 10

# Setups .autrc configuration file
log_command "Setting up .autrc configuration file"
tee <<EOF >/dev/null $HOME/.autrc
[aut]
rpc_endpoint= ws://127.0.0.1:8546
keyfile= ~/.autonity/keystore/treasury.key
EOF

# start autonity node
docker compose up -d autonity

# done
echo  "Installation completed"
sleep 5
echo -e "to check node logs: \e[1mdocker logs -f --tail=10 autonity\e[0m"
echo -e "to check node sync: \e[1maut node info | jq '{eth_blockNumber, eth_syncing}'\e[0m" if false your node is synced
