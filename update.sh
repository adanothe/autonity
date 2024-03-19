#!/bin/bash

mkdir -p $HOME/backup
cp $HOME/autonity/.env $HOME/backup
rm -rf /usr/bin/autonity
rm -rf autonity
git clone https://github.com/adanothe/autonity.git
sudo cp $HOME/autonity/bin/autonity /usr/bin/ && sudo chmod +x /usr/bin/autonity
sudo cp -f $HOME/backup/.env $HOME/autonity
chmod +x $HOME/autonity/tools/*
chmod +x $HOME/autonity/tools/cax/*

if ! command -v http &> /dev/null; then
    echo "Installing HTTPie..."
    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    sudo echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" > /etc/apt/sources.list.d/httpie.list
    sudo apt update
    sudo apt install httpie -y
    echo "HTTPie installed successfully."
fi

