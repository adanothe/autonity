#!/bin/bash

UBUNTU_VERSION=$(lsb_release -r | awk '{print $2}')

if command -v aut &>/dev/null; then
    echo "autonity-cli is already installed. Skipping installation."
    exit 0
fi

if [[ "$UBUNTU_VERSION" == "20.04" ]]; then
    echo "Ubuntu 20.04 Detected. Installing Python 3.8 and pipx..."
    sudo apt update
    sudo apt install -y python3-pip python3.8-venv
    pip install --upgrade pipx
elif [[ "$UBUNTU_VERSION" == "22.04" ]]; then
    echo "Ubuntu 22.04 Detected. Installing Python 3.10 and pipx..."
    sudo apt update
    sudo apt install -y python3-pip python3.10-venv
    pip install --upgrade pipx
else
    echo "Unsupported Ubuntu version: $UBUNTU_VERSION. This script supports Ubuntu 20.04 and 22.04 only."
    exit 1
fi

pipx install autonity-cli
sudo mv $HOME/.local/bin/aut /usr/local/bin/aut
