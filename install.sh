#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Define directories and environment variables
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
HTTP_PACKAGES="httpie gnupg2"
UBUNTU_VERSION=$(lsb_release -rs)

# Install Docker if not exists
if ! command_exists docker; then
    echo "Installing Docker..."
    curl -sSfL "$DOCKER_INSTALL_SCRIPT" | sudo sh && echo "Docker installed successfully."
fi

# Install Go if not exists
if ! command_exists go; then
    echo "Installing Go..."
    curl -sSfL "$GO_INSTALL_SCRIPT" | sudo bash && echo "Go installed successfully."
fi

# Determine Python packages based on Ubuntu version
if [[ $UBUNTU_VERSION == "20."* ]]; then
    PYTHON_PACKAGES="python3-pip python3.8-venv"
elif [[ $UBUNTU_VERSION == "22."* ]]; then
    PYTHON_PACKAGES="python3-pip python3.10-venv"
else
    echo "Unsupported Ubuntu version: $UBUNTU_VERSION"
    exit 1
fi

# Install Python packages if not installed
if ! dpkg -s $PYTHON_PACKAGES &>/dev/null; then
    echo "Installing Python dependencies..."
    sudo apt install -y $PYTHON_PACKAGES && echo "Python dependencies installed successfully."
fi

# Install pipx if not exists
if ! command_exists pipx; then
    echo "Installing pipx..."
    sudo python3 -m pip install --upgrade pipx && echo "pipx installed successfully."
fi

# Install AUT if not exists
if ! command_exists aut; then
    echo "Installing AUT..."
    pipx install --force git+https://github.com/autonity/aut && sudo mv "$HOME/.local/bin/aut" /usr/local/bin/aut && echo "AUT installed successfully."
fi

# Install HTTPie if not exists
if ! command_exists http; then
    echo "Installing HTTPie..."
    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list
    sudo apt update && sudo apt install -y httpie && echo "HTTPie installed successfully."
fi

# Install Expect if not exists
if ! command_exists expect; then
    echo "Installing Expect..."
    sudo apt install -y expect && echo "Expect installed successfully."
fi

# Clone Autonity repository
echo "Cloning tools repository..."
git clone https://github.com/adanothe/autonity.git "$AUTONITY_DIR" && echo "Tools repository cloned successfully."

# Read and store KEYPASSWORD
read -sp "Enter your KEYPASSWORD: " KEYPASSWORD
echo "KEYPASSWORD=$KEYPASSWORD" >"$AUTONITY_ENV"
echo "YOURIP=$(curl -4 ifconfig.me)" >>"$AUTONITY_ENV"

# Move binaries and set permissions
echo "Moving ethkey and autonity CLI..."
sudo cp "$AUTONITY_BIN/ethkey" /usr/bin/ && sudo chmod +x /usr/bin/ethkey
sudo cp "$AUTONITY_BIN/autonity" /usr/bin/ && sudo chmod +x /usr/bin/autonity
echo "ethkey and autonity CLI moved successfully."

# Move plugins configuration
echo "Moving plugins-conf.yml..."
cp "$AUTONITY_PLUGINS/plugins-conf.yml" "$AUTONITY_ORACLE" && echo "plugins-conf.yml moved successfully."

# Set execution permissions for scripts
echo "Changing execution permissions for scripts..."
chmod +x "$AUTONITY_TOOLS/"* "$AUTONITY_TOOLS/cax/"* && echo "Execution permissions changed successfully."

# Create wallet
echo "Creating wallet..."
"$AUTONITY_TOOLS/create-wallet.sh" && echo "Wallet created successfully."
echo "Your wallet password is $KEYPASSWORD"
sleep 5

# Setup .autrc configuration file
echo "Setting up .autrc configuration file..."
cat <<EOF >"$AUTONITY_ETC"
[aut]
rpc_endpoint=ws://127.0.0.1:8546
keyfile=~/.autonity/keystore/treasury.key
EOF
echo ".autrc configuration file set up successfully."

echo "Installation completed"
sleep 5
echo -e "To start node: \e[1mautonity node start\e[0m"
echo -e "To check node logs: \e[1mautonity node logs\e[0m"
echo -e "To check node sync: \e[1mautonity node sync\e[0m"
