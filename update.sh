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
