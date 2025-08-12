#!/usr/bin/env bash

set -euo pipefail

readonly AUTONITY_HOME="$HOME/autonity"
readonly KEY_HOME="$HOME/.autonity"
readonly KEYSTORE_DIR="$KEY_HOME/keystore"
readonly ORACLE_DIR="$KEY_HOME/oracle"
readonly TOOLS_DIR="$AUTONITY_HOME/tools"
readonly SCRIPTS_DIR="$AUTONITY_HOME/scripts"
readonly BIN_DIR="$AUTONITY_HOME/bin"
readonly ENV_FILE="$AUTONITY_HOME/.env"
readonly ENV_EXAMPLE_FILE="$AUTONITY_HOME/.env.example"
readonly AUTRC_FILE="$HOME/.autrc"
readonly PLUGINS_CONF="$AUTONITY_HOME/plugins/oracle_config.yml"

log_step() {
    echo -e "\n🌀 Step: $1"
    echo "--------------------------------------------------"
}

die() {
    printf "❌ Error: %s\n" "$1" >&2
    exit 1
}

confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
    [yY][eE][sS] | [yY])
        true
        ;;
    *)
        false
        ;;
    esac
}

setup_env_file() {
    log_step "Setting up .env configuration file"
    if [[ ! -f "$ENV_EXAMPLE_FILE" ]]; then
        die ".env.example not found at '$ENV_EXAMPLE_FILE'. Cannot proceed."
    fi
    cp "$ENV_EXAMPLE_FILE" "$ENV_FILE"
    echo "✅ Copied .env.example to .env"
}

configure_env_vars() {
    log_step "Configuring environment variables"

    local password your_ip

    read -sp "Enter a secure password for your wallet: " password
    echo
    if [[ -z "$password" ]]; then
        die "Password cannot be empty."
    fi

    echo "Fetching public IP address..."
    your_ip=$(curl --ipv4 --silent --fail ifconfig.me) || die "Unable to fetch public IP address. Check your internet connection."
    echo "✅ Public IP address is: $your_ip"

    local temp_env
    temp_env=$(mktemp)
    grep -v '^KEYPASSWORD=' "$ENV_FILE" >"$temp_env" || true
    echo "KEYPASSWORD=${password}" >>"$temp_env"
    mv "$temp_env" "$ENV_FILE"

    temp_env=$(mktemp)
    grep -v '^YOURIP=' "$ENV_FILE" >"$temp_env" || true
    echo "YOURIP=${your_ip}" >>"$temp_env"
    mv "$temp_env" "$ENV_FILE"

    if ! grep -qF 'RPC_URL=' "$ENV_FILE"; then
        echo "RPC_URL=ws://127.0.0.1:8546" >>"$ENV_FILE"
    fi

    echo "✅ .env file has been configured securely."
}

create_configs_and_dirs() {
    log_step "Creating directories and config files"
    mkdir -p "$KEYSTORE_DIR" "$ORACLE_DIR"
    echo "✅ Created necessary directories."

    cat <<EOF >"$AUTRC_FILE"
[aut]
rpc_endpoint=ws://127.0.0.1:8546
keyfile=~/.autonity/keystore/treasury.key
EOF
    echo "✅ Created .autrc configuration file."

    if [[ -f "$PLUGINS_CONF" ]]; then
        cp "$PLUGINS_CONF" "$ORACLE_DIR"
        echo "✅ Copied oracle configuration."
    else
        echo "⚠️  Warning: oracle_config.yml not found, skipping copy."
    fi
}

set_permissions() {
    log_step "Setting executable permissions for scripts"
    for dir in "$TOOLS_DIR" "$SCRIPTS_DIR" "$BIN_DIR"; do
        if [[ -d "$dir" ]]; then
            find "$dir" -type f -exec chmod +x {} +
            echo "✅ Set permissions for files in $dir"
        else
            echo "⚠️  Warning: Directory '$dir' not found, skipping permissions."
        fi
    done
}

install_binaries() {
    log_step "Installing command-line tools"

    if [[ ! -d "$BIN_DIR" ]] || [[ -z "$(ls -A "$BIN_DIR")" ]]; then
        echo "✅ No binaries found in '$BIN_DIR'. Nothing to install."
        return
    fi

    echo "This script needs to add '$BIN_DIR' to your shell's PATH."
    echo "This will allow you to run commands like 'autonity' from anywhere."

    if confirm "Do you want to add '$BIN_DIR' to your PATH in your shell configuration file? [y/N]"; then
        local shell_config_file
        case "$SHELL" in
        */bash) shell_config_file="$HOME/.bashrc" ;;
        */zsh) shell_config_file="$HOME/.zshrc" ;;
        *)
            echo "⚠️  Could not detect your shell. Please add the following line to your shell config file manually:"
            echo "   export PATH=\"\$PATH:$BIN_DIR\""
            return
            ;;
        esac

        if ! grep -qF "export PATH=\"\$PATH:$BIN_DIR\"" "$shell_config_file"; then
            echo -e "\n# Add Autonity binaries to PATH\nexport PATH=\"\$PATH:$BIN_DIR\"" >>"$shell_config_file"
            echo "✅ '$BIN_DIR' has been added to your PATH in '$shell_config_file'."
            echo "   Please run 'source $shell_config_file' or open a new terminal to use the commands."
        else
            echo "✅ Path is already configured. No changes needed."
        fi
    else
        echo "Skipping PATH modification. You will need to run commands using their full path."
    fi
}

# Main function to orchestrate the setup process.
main() {
    echo "Starting Autonity Setup..."

    setup_env_file
    configure_env_vars
    create_configs_and_dirs
    set_permissions

    log_step "Running core installation scripts"
    if [[ -x "$SCRIPTS_DIR/docker.sh" && -x "$SCRIPTS_DIR/aut.sh" && -x "$SCRIPTS_DIR/package.sh" ]]; then
        "$SCRIPTS_DIR/docker.sh"
        "$SCRIPTS_DIR/aut.sh"
        "$SCRIPTS_DIR/package.sh"
        echo "✅ Core installation scripts executed successfully."
    else
        die "One or more required scripts (docker.sh, aut.sh, package.sh) not found or not executable."
    fi

    install_binaries

    echo -e "\n🎉 Setup complete! 🎉"
}

# Run the script
main
