#!/bin/bash

command_exists() {
    command -v "$1" &>/dev/null
}

update_env_var() {
    local var_name=$1
    local var_value=$2
    local env_file=$3

    if grep -q "^$var_name=" "$env_file"; then
        sed -i "s|^$var_name=.*|$var_name=$var_value|" "$env_file"
    else
        echo "$var_name=$var_value" >> "$env_file"
    fi
}

HOME_DIR="$HOME"
AUTONITY_DIR="$HOME_DIR/autonity"
AUTONITY_BIN="$AUTONITY_DIR/bin"
AUTONITY_TOOLS="$AUTONITY_DIR/tools"
AUTONITY_PLUGINS="$AUTONITY_DIR/plugins"
AUTONITY_KEYSTORE="$HOME_DIR/.autonity/keystore"
AUTONITY_ORACLE="$HOME_DIR/.autonity/oracle"
AUTONITY_ENV="$AUTONITY_DIR/.env"
AUTRC_FILE="$HOME_DIR/.autrc"
DOCKER_INSTALL_SCRIPT="https://raw.githubusercontent.com/Dedenwrg/dependencies/main/docker/docker.sh"
GO_INSTALL_SCRIPT="https://raw.githubusercontent.com/Dedenwrg/dependencies/main/golang/go.sh"
HTTP_PACKAGES="httpie gnupg2"
UBUNTU_VERSION=$(lsb_release -rs)

mkdir -p "$AUTONITY_ORACLE"

if ! command_exists docker; then
    curl -sSfL "$DOCKER_INSTALL_SCRIPT" | sudo sh
fi

if ! command_exists go; then
    curl -sSfL "$GO_INSTALL_SCRIPT" | sudo bash 
fi

if [[ $UBUNTU_VERSION == "20."* ]]; then
    PYTHON_PACKAGES="python3-pip python3.8-venv"
elif [[ $UBUNTU_VERSION == "22."* ]]; then
    PYTHON_PACKAGES="python3-pip python3.10-venv"
else
    echo "Unsupported Ubuntu version: $UBUNTU_VERSION"
    exit 1
fi

if ! dpkg -s $PYTHON_PACKAGES &>/dev/null; then
    sudo apt install -y $PYTHON_PACKAGES 
fi

if ! command_exists pipx; then
    sudo python3 -m pip install --upgrade pipx 
fi

if ! command_exists aut; then
    pipx install --force git+https://github.com/autonity/aut && sudo mv "$HOME/.local/bin/aut" /usr/local/bin/aut
fi

if ! command_exists http; then
    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list
    sudo apt update && sudo apt install -y httpie
fi

if ! command_exists expect; then
    sudo apt install -y expect 
fi

git clone https://github.com/adanothe/autonity.git > /dev/null
sudo cp "$AUTONITY_BIN/ethkey" /usr/bin/ && sudo chmod +x /usr/bin/ethkey
sudo cp "$AUTONITY_BIN/autonity" /usr/bin/ && sudo chmod +x /usr/bin/autonity
cp "$AUTONITY_PLUGINS/plugins-conf.yml" "$AUTONITY_ORACLE"
chmod +x "$AUTONITY_TOOLS/"* "$AUTONITY_TOOLS/cax/"*

echo "Do you want to create a new validator or use an existing one?"
select choice in "Create New Validator" "Use Existing Validator"; do
    case $choice in
        "Create New Validator")
            read -sp "Enter your KEYPASSWORD: " KEYPASSWORD
            update_env_var "KEYPASSWORD" "$KEYPASSWORD" "$AUTONITY_ENV"
            update_env_var "YOURIP" "$(curl -4 ifconfig.me)" "$AUTONITY_ENV"

            cat <<EOF >"$AUTRC_FILE"
[aut]
rpc_endpoint= ws://127.0.0.1:8546
keyfile= ~/.autonity/keystore/treasury.key
EOF
            "$AUTONITY_TOOLS/create-wallet.sh" > /dev/null && echo "Wallet created successfully."
            break
            ;;
        "Use Existing Validator")
            read -p "Enter your old node IP: " YOURIP
            read -sp "Enter your KEYPASSWORD: " KEYPASSWORD
            update_env_var "YOURIP" "$YOURIP" "$AUTONITY_ENV"
            update_env_var "KEYPASSWORD" "$KEYPASSWORD" "$AUTONITY_ENV"

            KEYSTOREDIR=~/.autonity/keystore
            mkdir -p "$KEYSTOREDIR"
            echo "Please move your wallet backup to $KEYSTOREDIR with the file name oracle.key and treasury.key."

            mkdir -p ~/autonity-chaindata/autonity
            echo "Please move your autonitykeys backup to ~/autonity-chaindata/autonity."

            read -p "Enter your validator address: " VALIDATOR_ADDRESS
            cat <<EOF >"$AUTRC_FILE"
[aut]
rpc_endpoint= ws://127.0.0.1:8546
keyfile= ~/.autonity/keystore/treasury.key
validator= $VALIDATOR_ADDRESS
EOF
            break
            ;;
    esac
done

echo "Installation completed"
sleep 5
echo -e "To start node: \e[1mautonity node start\e[0m"
echo -e "To check node logs: \e[1mautonity node logs\e[0m"
echo -e "To check node sync: \e[1mautonity node sync\e[0m"
