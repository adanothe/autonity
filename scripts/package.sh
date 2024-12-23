#!/bin/bash

HOME_DIR="$HOME"
REQUIREMENTS_FILE="$HOME_DIR/autonity/tiber-task/requirements.txt"
VENV_DIR="$HOME_DIR/.autvenv"

UBUNTU_VERSION=$(lsb_release -r | awk '{print $2}')
echo "Ubuntu Version: $UBUNTU_VERSION"

if ! command -v python3 &> /dev/null
then
    echo "Python3 not found. Installing Python3..."
    sudo apt update
    sudo apt install -y python3 python3-venv python3-pip
fi

if [ -d "$VENV_DIR" ]; then
    echo ".venv already exists, activating the virtual environment..."
    source $VENV_DIR/bin/activate
else
    echo "Creating virtual environment at $VENV_DIR..."
    python3 -m venv $VENV_DIR
    source $VENV_DIR/bin/activate
fi

if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing dependencies from $REQUIREMENTS_FILE..."
    pip install -r $REQUIREMENTS_FILE
else
    echo "$REQUIREMENTS_FILE not found."
fi

echo "Setup complete."
