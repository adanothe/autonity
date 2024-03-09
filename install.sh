#!/bin/bash

# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)

AUTONITY=$(which autonity)

# Create a folder for Autonity
mkdir -p $HOME/.autonity/oracle 

# Check if Docker is already installed
if ! command -v docker &> /dev/null; then
    # Install Docker
    curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/Dedenwrg/dependencies/main/docker/docker.sh | sudo sh 
fi

# Check if Go is already installed
if ! command -v go &> /dev/null; then
    # Install Go
    curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/Dedenwrg/dependencies/main/golang/go.sh | sudo bash 
fi

# Install AUT dependencies if not already installed
if [[ $UBUNTU_VERSION == "20."* ]]; then
    if ! dpkg -s python3-pip python3.8-venv &> /dev/null; then
        sudo apt install python3-pip python3.8-venv -y 
    fi
elif [[ $UBUNTU_VERSION == "22."* ]]; then
    if ! dpkg -s python3-pip python3.10-venv &> /dev/null; then
        sudo apt install python3-pip python3.10-venv -y 
    fi
else
    exit 1
fi

# Install pipx if not already installed
if ! command -v pipx &> /dev/null; then
    sudo python3 -m pip install --upgrade pipx >/dev/null 2>&1
fi

# Check if AUT is already installed
if ! command -v aut &> /dev/null; then
    # Install AUT
    pipx install --force git+https://github.com/autonity/aut && sudo mv $HOME/.local/bin/aut /usr/local/bin/aut >/dev/null 2>&1
fi

# Clone tools repository
git clone https://github.com/adanothe/autonity.git 
cd autonity

# Export KEYPASSWORD and YOURIP to .env file
read -p "Enter your KEYPASSWORD: " KEYPASSWORD
echo "KEYPASSWORD=$KEYPASSWORD" > $HOME/autonity/.env
echo "YOURIP=$(curl -4 ifconfig.me)" >> $HOME/autonity/.env

# Move ethkey & autonity cli
sudo cp $HOME/autonity/bin/ethkey /usr/bin/ && sudo chmod +x /usr/bin/ethkey 
sudo cp $HOME/autonity/bin/autonity /usr/bin/ && sudo chmod +x /usr/bin/autonity


# Move plugins-conf.yml
cp $HOME/autonity/plugins/plugins-conf.yml $HOME/.autonity/oracle >/dev/null 2>&1

# Change execution permission for scripts inside autonity/tools
chmod +x $HOME/autonity/tools/* >/dev/null 2>&1

# Create wallet
$HOME/autonity/tools/create-wallet.sh >/dev/null 2>&1
echo "your wallet password is $KEYPASSWORD"
sleep 5

# Setups .autrc configuration file
tee <<EOF >/dev/null $HOME/.autrc
[aut]
rpc_endpoint= ws://127.0.0.1:8546
keyfile= ~/.autonity/keystore/treasury.key
EOF

# start autonity node
$AUTONITY node start >/dev/null 2>&1

# done
echo  "Installation completed"
sleep 5
echo -e "to check node logs: \e[1mautonity node logs\e[0m"
echo -e "to check node sync: \e[1mautonity node sync\e[0m" if false your node is synced
