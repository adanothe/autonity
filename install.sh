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

home_dir="$HOME"
autonity_dir="$home_dir/autonity"
autonity_bin="$autonity_dir/bin"
autonity_tools="$autonity_dir/tools"
autonity_plugins="$autonity_dir/plugins"
autonity_keystore="$home_dir/.autonity/keystore"
autonity_oracle="$home_dir/.autonity/oracle"
autonity_env="$autonity_dir/.env"
autrc_file="$home_dir/.autrc"
docker_install_script="https://raw.githubusercontent.com/Dedenwrg/dependencies/main/docker/docker.sh"
go_install_script="https://raw.githubusercontent.com/Dedenwrg/dependencies/main/golang/go.sh"
http_packages="httpie gnupg2"
rpc="https://rpc1.piccadilly.autonity.org"
ubuntu_version=$(lsb_release -rs)

mkdir -p "$autonity_oracle"

if ! command_exists docker; then
    curl -sSfL "$docker_install_script" | sudo sh
fi

if ! command_exists go; then
    curl -sSfL "$go_install_script" | sudo bash
fi

if [[ $ubuntu_version == "20."* ]]; then
    python_packages="python3-pip python3.8-venv"
elif [[ $ubuntu_version == "22."* ]]; then
    python_packages="python3-pip python3.10-venv"
else
    echo "Unsupported Ubuntu version: $ubuntu_version"
    exit 1
fi

if ! dpkg -s $python_packages &>/dev/null; then
    sudo apt install -y $python_packages
fi

if ! command_exists pipx; then
    sudo python3 -m pip install --upgrade pipx
fi

if ! command_exists aut; then
    pipx install --force git+https://github.com/autonity/aut && sudo mv "$home_dir/.local/bin/aut" /usr/local/bin/aut
fi

if ! command_exists http; then
    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list
    sudo apt update && sudo apt install -y httpie
fi

git clone https://github.com/adanothe/autonity.git > /dev/null
sudo cp "$autonity_bin/ethkey" /usr/bin/ && sudo chmod +x /usr/bin/ethkey
sudo cp "$autonity_bin/autonity" /usr/bin/ && sudo chmod +x /usr/bin/autonity
cp "$autonity_plugins/plugins-conf.yml" "$autonity_oracle"
chmod +x "$autonity_tools/"* "$autonity_tools/cax/"*

echo "Do you want to create a new validator or use an existing one?"
select choice in "Create New Validator" "Use Existing Validator"; do
    case $choice in
        "Create New Validator")
            read -sp "Enter your key password: " keypassword
            update_env_var "KEYPASSWORD" "$keypassword" "$autonity_env"
            update_env_var "YOURIP" "$(curl -4 ifconfig.me)" "$autonity_env"

            cat <<EOF >"$autrc_file"
[aut]
rpc_endpoint= ws://127.0.0.1:8546
keyfile= ~/.autonity/keystore/treasury.key
EOF
            "$autonity_tools/create-wallet.sh" > /dev/null && echo "Wallet created successfully."
            echo "Installation completed"
            sleep 5
            break
            ;;
        "Use Existing Validator")
            read -sp "Enter your key password: " keypassword
            read -p "Please enter your validator IP address. You can find it in the previous round's validator task registration email under the enode section: " ip
            update_env_var "YOURIP" "$ip" "$autonity_env"
            update_env_var "KEYPASSWORD" "$keypassword" "$autonity_env"

            keystoredir="$home_dir/.autonity/keystore"
            mkdir -p "$autonity_keystore"
            mkdir -p "$home_dir/autonity-chaindata/autonity"

            cat <<EOF >"$autrc_file"
[aut]
rpc_endpoint= ws://127.0.0.1:8546
keyfile= ~/.autonity/keystore/treasury.key
EOF
            echo "Installation completed"
            sleep 5
            echo "Please move your wallet backup to $autonity_keystore with the file name oracle.key and treasury.key."
            echo "Please move your autonitykeys backup to $home_dir/autonity-chaindata/autonity."
            break
            ;;
    esac
done

echo -e "to start node: \e[1mautonity node start\e[0m"
echo -e "to check node logs: \e[1mautonity node logs\e[0m"
echo -e "to check node sync: \e[1mautonity node sync\e[0m"
