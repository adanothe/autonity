#!/bin/bash

UBUNTU_VERSION=$(lsb_release -rs)
AUTONITY=$(which autonity)

mkdir -p $HOME/.autonity/oracle 

if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/Dedenwrg/dependencies/main/docker/docker.sh | sudo sh 
    echo "Docker installed successfully."
fi

if ! command -v go &> /dev/null; then
    echo "Installing Go..."
    curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/Dedenwrg/dependencies/main/golang/go.sh | sudo bash 
    echo "Go installed successfully."
fi

if [[ $UBUNTU_VERSION == "20."* ]]; then
    if ! dpkg -s python3-pip python3.8-venv &> /dev/null; then
        echo "Installing Python 3.8 dependencies..."
        sudo apt install python3-pip python3.8-venv -y 
        echo "Python 3.8 dependencies installed successfully."
    fi
elif [[ $UBUNTU_VERSION == "22."* ]]; then
    if ! dpkg -s python3-pip python3.10-venv &> /dev/null; then
        echo "Installing Python 3.10 dependencies..."
        sudo apt install python3-pip python3.10-venv -y 
        echo "Python 3.10 dependencies installed successfully."
    fi
else
    exit 1
fi

if ! command -v pipx &> /dev/null; then
    echo "Installing pipx..."
    sudo python3 -m pip install --upgrade pipx >/dev/null 2>&1
    echo "pipx installed successfully."
fi

if ! command -v aut &> /dev/null; then
    echo "Installing AUT..."
    pipx install --force git+https://github.com/autonity/aut && sudo mv $HOME/.local/bin/aut /usr/local/bin/aut >/dev/null 2>&1
    echo "AUT installed successfully."
fi

if ! command -v http &> /dev/null; then
    echo "Installing HTTPie..."
    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" > /etc/apt/sources.list.d/httpie.list
    sudo apt update
    sudo apt install httpie -y
    echo "HTTPie installed successfully."
fi

echo "Cloning tools repository..."
git clone https://github.com/adanothe/autonity.git 
cd autonity
echo "Tools repository cloned successfully."

read -p "Enter your KEYPASSWORD: " KEYPASSWORD
echo "KEYPASSWORD=$KEYPASSWORD" > $HOME/autonity/.env
echo "YOURIP=$(curl -4 ifconfig.me)" >> $HOME/autonity/.env

echo "Moving ethkey and autonity cli..."
sudo cp $HOME/autonity/bin/ethkey /usr/bin/ && sudo chmod +x /usr/bin/ethkey 
sudo cp $HOME/autonity/bin/autonity /usr/bin/ && sudo chmod +x /usr/bin/autonity
echo "ethkey and autonity cli moved successfully."

echo "Moving plugins-conf.yml..."
cp $HOME/autonity/plugins/plugins-conf.yml $HOME/.autonity/oracle >/dev/null 2>&1
echo "plugins-conf.yml moved successfully."

echo "Changing execution permission for scripts..."
chmod +x $HOME/autonity/tools/* >/dev/null 2>&1
chmod +x $HOME/autonity/tools/cax/* >/dev/null 2>&1
echo "Execution permission changed successfully."

echo "Creating wallet..."
$HOME/autonity/tools/create-wallet.sh >/dev/null 2>&1
echo "Wallet created successfully."
echo "Your wallet password is $KEYPASSWORD"
sleep 5

echo "Setting up .autrc configuration file..."
tee <<EOF >/dev/null $HOME/.autrc
[aut]
rpc_endpoint= ws://127.0.0.1:8546
keyfile= ~/.autonity/keystore/treasury.key
EOF
echo ".autrc configuration file set up successfully."

echo  "Installation completed"
sleep 5
echo -e "To start node: \e[1mautonity node start\e[0m"
echo -e "To check node logs: \e[1mautonity node logs\e[0m"
echo -e "To check node sync: \e[1mautonity node sync\e[0m" if false your node is synced
