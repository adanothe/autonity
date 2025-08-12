#!/usr/bin/env bash

set -euo pipefail

die() {
    printf "Error: %s\n" "$1" >&2
    exit 1
}

check_prerequisites() {
    for cmd in aut jq bc; do
        command -v "$cmd" &>/dev/null || die "Command '$cmd' not found. Please install it."
    done
}

main() {
    check_prerequisites

    local committee_data
    committee_data=$(aut protocol committee)

    if [[ -z "$committee_data" ]]; then
        die "Failed to get committee data from 'aut' command."
    fi

    printf "+-------+------------------------------------------+--------------------+\n"
    printf "| %-5s | %-40s | %-18s |\n" "No." "Validator Address" "Voting Power (NTN)"
    printf "+-------+------------------------------------------+--------------------+\n"

    local counter=0
    echo "$committee_data" | jq -c '.[]' | while IFS= read -r member_json; do
        counter=$((counter + 1))

        local address raw_power
        address=$(echo "$member_json" | jq -r '.addr')
        raw_power=$(echo "$member_json" | jq -r '.voting_power')

        local formatted_power
        formatted_power=$(bc <<<"scale=6; ${raw_power} / 1000000000000000000")

        printf "| %-5d | %-40s | %-18.6f |\n" "$counter" "$address" "$formatted_power"
    done

    printf "+-------+------------------------------------------+--------------------+\n"
}

main
