#!/bin/bash

command_exists() {
    command -v "$1" &>/dev/null
}

HOME_DIR="$HOME"
AUTONITY_DIR="$HOME_DIR/autonity"
AUTONITY_BIN="$AUTONITY_DIR/bin"
AUTONITY_TOOLS="$AUTONITY_DIR/tools"
AUTONITY_PLUGINS="$AUTONITY_DIR/plugins"
AUTONITY_KEYSTORE="$HOME_DIR/.autonity/keystore"
AUTONITY_ORACLE="$HOME_DIR/.autonity/oracle"
AUTONITY_ENV="$AUTONITY_DIR/.env"
AUTONITY_ETC="$HOME_DIR/.autrc"

DOCKER_INSTALL_SCRIPT="https://raw.githubusercontent.com/Dedenwrg/dependencies/main/docker/docker.sh"
GO_INSTALL_SCRIPT="https://raw.githubusercontent.com/Dedenwrg/dependencies/main/golang/go.sh"
PYTHON_PACKAGES=""
HTTP_PACKAGES="httpie gnupg2"
UBUNTU_VERSION=$(lsb_release -rs)

if ! command_exists docker; then
    echo "Installing Docker..."
    curl --proto '=https' --tlsv1.2 -sSfL "$DOCKER_INSTALL_SCRIPT" | sudo sh
    echo "Docker installed successfully."
fi

if ! command_exists go; then
    echo "Installing Go..."
    curl --proto '=https' --tlsv1.2 -sSfL "$GO_INSTALL_SCRIPT" | sudo bash
    echo "Go installed successfully."
fi

if [[ $UBUNTU_VERSION == "20."* ]]; then
    PYTHON_PACKAGES="python3-pip python3.8-venv"
elif [[ $UBUNTU_VERSION == "22."* ]]; then
    PYTHON_PACKAGES="python3-pip python3.10-venv"
else
    exit 1
fi

if ! dpkg -s $PYTHON_PACKAGES &>/dev/null; then
    echo "Installing Python dependencies..."
    sudo apt install $PYTHON_PACKAGES -y
    echo "Python dependencies installed successfully."
fi

if ! command_exists pipx; then
    echo "Installing pipx..."
    sudo python3 -m pip install --upgrade pipx >/dev/null 2>&1
    echo "pipx installed successfully."
fi

if ! command_exists aut; then
    echo "Installing AUT..."
    pipx install --force git+https://github.com/autonity/aut && sudo mv "$HOME/.local/bin/aut" /usr/local/bin/aut >/dev/null 2>&1
    echo "AUT installed successfully."
fi

if ! command_exists http; then
    echo "Installing HTTPie..."
    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" >/etc/apt/sources.list.d/httpie.list
    sudo apt update
    sudo apt install httpie -y
    echo "HTTPie installed successfully."
fi

# Add Expect installation
if ! command_exists expect; then
    echo "Installing Expect..."
    sudo apt install expect -y
    echo "Expect installed successfully."
fi

echo "Cloning tools repository..."
git clone https://github.com/adanothe/autonity.git "$AUTONITY_DIR"
echo "Tools repository cloned successfully."

read -p "Enter your KEYPASSWORD: " KEYPASSWORD
echo "KEYPASSWORD=$KEYPASSWORD" >"$AUTONITY_ENV"
echo "YOURIP=$(curl -4 ifconfig.me)" >>"$AUTONITY_ENV"

echo "Moving ethkey and autonity cli..."
sudo cp "$AUTONITY_BIN/ethkey" /usr/bin/ && sudo chmod +x /usr/bin/ethkey
sudo cp "$AUTONITY_BIN/autonity" /usr/bin/ && sudo chmod +x /usr/bin/autonity
echo "ethkey and autonity cli moved successfully."

echo "Moving plugins-conf.yml..."
cp "$AUTONITY_PLUGINS/plugins-conf.yml" "$AUTONITY_ORACLE" >/dev/null 2>&1
echo "plugins-conf.yml moved successfully."

echo "Changing execution permission for scripts..."
chmod +x "$AUTONITY_TOOLS/"* "$AUTONITY_TOOLS/cax/"* >/dev/null 2>&1
echo "Execution permission changed successfully."

echo "Creating wallet..."
"$AUTONITY_TOOLS/create-wallet.sh" >/dev/null 2>&1
echo "Wallet created successfully."
echo "Your wallet password is $KEYPASSWORD"
sleep 5

echo "Setting up .autrc configuration file..."
cat <<EOF >"$AUTONITY_ETC"
[aut]
rpc_endpoint= ws://127.0.0.1:8546
keyfile= ~/.autonity/keystore/treasury.key
EOF
echo ".autrc configuration file set up successfully."

echo "Installation completed"
sleep 5
echo -e "To start node: \e[1mautonity node start\e[0m"
echo -e "To check node logs: \e[1mautonity node logs\e[0m"
echo -e "To check node sync: \e[1mautonity node sync\e[0m" if false your node is synced
