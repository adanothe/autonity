#!/bin/bash

backup_dir="$HOME/backup"
autonity_dir="$HOME/autonity"
repo_url="https://github.com/adanothe/autonity.git"
bin_dir="/usr/bin"

mkdir -p "$backup_dir"
cp -f "$autonity_dir/.env" "$backup_dir"
cp -f "$autonity_dir/docker-compose.yml" "$backup_dir"
sudo rm -rf "$bin_dir/autonity"
rm -rf "$autonity_dir"

git clone "$repo_url" "$autonity_dir"
sudo cp "$autonity_dir/bin/autonity" "$bin_dir" && sudo chmod +x "$bin_dir/autonity"
cp -f "$backup_dir/.env" "$autonity_dir"
cp -f "$backup_dir/docker-compose.yml" "$autonity_dir"
chmod +x "$autonity_dir/tools/"*
chmod +x "$autonity_dir/tools/cax/"*
