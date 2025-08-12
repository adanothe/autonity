#!/usr/bin/env bash

set -euo pipefail

die() {
    printf "❌ Error: %s\n" "$1" >&2
    exit 1
}

check_prerequisites() {
    echo "🔎 Checking prerequisites..."

    local -r env_file="${HOME}/autonity/.env"

    for cmd in aut ethkey docker jq; do
        command -v "$cmd" &>/dev/null || die "Command '$cmd' not found. Please install it first."
    done

    [[ -f "$env_file" ]] || die ".env file not found at '$env_file'."
    [[ -f "${HOME}/.autonity/keystore/treasury.key" ]] || die "Treasury key file not found."
    [[ -f "${HOME}/.autonity/keystore/oracle.key" ]] || die "Oracle key file not found."
    [[ -f "${HOME}/.autonity/keystore/oracle.priv" ]] || die "Oracle private key file (.priv) not found."
    [[ -d "${HOME}/autonity-chaindata" ]] || die "Chaindata directory not found."
    [[ -f "${HOME}/autonity-chaindata/autonity/autonitykeys" ]] || die "Autonitykeys file not found."

    source "$env_file"
    [[ -z "${KEYPASSWORD:-}" ]] && die "KEYPASSWORD variable is not set in '$env_file'."
    export KEYFILEPWD="$KEYPASSWORD"

    echo "✅ All prerequisites met."
}

update_autrc_file() {
    local -r autrc_file="${HOME}/.autrc"
    local -r validator_address="$1"

    echo -e "\n📝 Step 4: Updating .autrc Configuration File..."
    if grep -q "^validator=" "$autrc_file"; then
        sed -i.bak "s|^validator=.*|validator=$validator_address|" "$autrc_file"
    else
        echo "validator=$validator_address" >>"$autrc_file"
    fi
    echo "✅ '$autrc_file' file updated."
}

main() {
    clear
    echo "Autonity Validator Registration"
    echo "-----------------------------------------------"

    check_prerequisites

    local -r autonity_keys_path="${HOME}/autonity-chaindata/autonity/autonitykeys"
    local -r treasury_key="${HOME}/.autonity/keystore/treasury.key"
    local -r oracle_key_file="${HOME}/.autonity/keystore/oracle.key"
    local -r oracle_priv_key="${HOME}/.autonity/keystore/oracle.priv"
    local -r docker_image="ghcr.io/autonity/autonity:latest"

    echo -e "\n🌀 Step 1: Gathering Initial Information..."
    local treasury_address
    treasury_address=$(aut account info --keyfile "$treasury_key" | jq -r '.[0].account' || true)
    [[ -z "$treasury_address" ]] && die "Failed to get account address from treasury key."

    local enode
    enode=$(aut node info | grep -o 'enode://[a-zA-Z0-9@.-]*:[0-9]*' || true)
    [[ -z "$enode" ]] && die "Failed to get enode from local node."

    local consensus_key
    consensus_key=$(ethkey autinspect "$autonity_keys_path" | awk '/Consensus Public Key/ {print $4}' || true)
    [[ -z "$consensus_key" ]] && die "Failed to get Consensus Public Key."

    local oracle_address
    oracle_address=$(aut account info --keyfile "$oracle_key_file" | jq -r '.[0].account' || true)
    [[ -z "$oracle_address" ]] && die "Failed to get account address from oracle key."
    echo "✅ Information gathered successfully."

    echo -e "\n🔐 Step 2: Generating Ownership Proof..."
    local proof
    proof=$(docker run --tty --interactive \
        --volume "${HOME}/autonity-chaindata:/autonity-chaindata" \
        --volume "$oracle_priv_key:/autoracle/oracle.key" \
        --rm \
        "$docker_image" \
        genOwnershipProof \
        --autonitykeys /autonity-chaindata/autonity/autonitykeys \
        --oraclekey /autoracle/oracle.key \
        "$treasury_address")

    proof=$(echo "$proof" | tr -cd '[:alnum:]')
    [[ -z "$proof" ]] && die "Failed to generate ownership proof."
    echo "✅ Proof generated successfully."

    echo -e "\n🚀 Step 3: Registering Validator and Sending Transaction..."
    local tx_hash
    tx_hash=$(aut validator register "$enode" "$oracle_address" "$consensus_key" "$proof" | aut tx sign - | aut tx send -)
    [[ -z "$tx_hash" ]] && die "Failed to send registration transaction."
    echo "✅ Transaction sent successfully."

    local validator_address
    validator_address=$(aut validator compute-address "$enode")

    update_autrc_file "$validator_address"

    echo -e "\n🏁 Step 5: Verifying Registration..."
    echo "Waiting a moment for the transaction to be processed on-chain..."
    sleep 15

    if aut validator info "$validator_address" &>/dev/null; then
        echo -e "\n🎉 Congratulations! Validator registration successful."
        echo "   Your Validator Address: $validator_address"
        echo "   Transaction Hash: $tx_hash"
    else
        echo -e "\n⚠️ Validator registration FAILED."
        echo "   The transaction was sent, but the validator is not yet registered on the network."
        echo "   Please check your node's logs and the transaction status manually."
        echo "   Transaction Hash: $tx_hash"
        exit 1
    fi
}

main
read -p $'\nPress Enter to exit.' -n1
