#!/bin/bash

UBUNTU_VERSION=$(lsb_release -r | awk '{print $2}')

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Determine Python version for venv installation
if [[ "$UBUNTU_VERSION" == "20.04" ]]; then
    PYTHON_VERSION="python3.8"
elif [[ "$UBUNTU_VERSION" == "22.04" ]]; then
    PYTHON_VERSION="python3.10"
else
    echo "Unsupported Ubuntu version: $UBUNTU_VERSION. This script supports Ubuntu 20.04 and 22.04 only."
    exit 1
fi

# Check if pip is installed
if command_exists pip; then
    echo "pip is already installed. Skipping installation."
else
    echo "pip is not installed. Proceeding with installation."
    INSTALL_PIP=true
fi

# Check if venv is installed
if "$PYTHON_VERSION" -m venv --help &>/dev/null; then
    echo "Python venv module is already installed. Skipping installation."
else
    echo "Python venv module is not installed. Proceeding with installation."
    INSTALL_VENV=true
fi

# Check if aut-cli is installed
if command_exists aut; then
    echo "autonity-cli is already installed. Skipping installation."
else
    echo "autonity-cli is not installed. Proceeding with installation."
    INSTALL_AUT_CLI=true
fi

# Install missing components
if [[ "$INSTALL_PIP" == "true" || "$INSTALL_VENV" == "true" || "$INSTALL_AUT_CLI" == "true" ]]; then
    echo "Updating package list..."
    sudo apt update
fi

if [[ "$INSTALL_PIP" == "true" ]]; then
    echo "Installing pip..."
    sudo apt install -y python3-pip
    pip install --upgrade pipx
fi

if [[ "$INSTALL_VENV" == "true" ]]; then
    echo "Installing Python venv..."
    sudo apt install -y "$PYTHON_VERSION"-venv
fi

if [[ "$INSTALL_AUT_CLI" == "true" ]]; then
    echo "Installing autonity-cli..."
    pipx install autonity-cli
    sudo mv "$HOME/.local/bin/aut" /usr/local/bin/
fi

echo "All necessary components are installed."
