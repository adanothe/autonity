#!/usr/bin/env bash

set -euo pipefail

readonly BOLD=$(tput bold)
readonly BLUE=$(tput setaf 4)
readonly RESET=$(tput sgr0)

die() {
  printf "Error: %s\n" "$1" >&2
  exit 1
}

check_prerequisites() {
  for cmd in aut jq; do
    command -v "$cmd" &>/dev/null || die "Command '$cmd' not found. Please install it."
  done
}

main() {
  check_prerequisites

  local target_validator=${1:-}
  local validator_json

  if [[ -z "$target_validator" ]]; then
    echo "Displaying info for the default configured validator..."
    validator_json=$(aut validator info)
  else
    echo "Displaying info for validator: $target_validator"
    validator_json=$(aut validator info --validator "$target_validator")
  fi

  if [[ -z "$validator_json" || "$validator_json" == "null" ]]; then
    die "Failed to get validator data. Ensure the address is correct or 'aut' is configured."
  fi

  local node_address_lower
  node_address_lower=$(echo "$validator_json" | jq -r '.node_address | ascii_downcase')

  echo
  echo "$validator_json" | jq -r '
      "Treasury address             : \(.treasury)",
      "Node address                 : \(.node_address)",
      "Oracle address               : \(.oracle_address)",
      "Liquid contract              : \(.liquid_state_contract)",
      "Enode                        : \(.enode)",
      "Consensus key                : \(.consensus_key)",
      "Bonded stake                 : \(.bonded_stake / 1e18) NTN",
      "Liquid supply                : \(.liquid_supply / 1e18) NTN",
      "Self bonded stake            : \(.self_bonded_stake / 1e18) NTN",
      "Unbonding stake              : \(.unbonding_stake / 1e18) NTN",
      "Unbonding shares             : \(.unbonding_shares/ 1e18) NTN",
      "Self unbonding stake         : \(.self_unbonding_stake / 1e18) NTN",
      "Self unbonding shares        : \(.self_unbonding_shares / 1e18) NTN",
      "Self unbonding stake locked  : \(.self_unbonding_stake_locked / 1e18) NTN",
      "Commission rate              : \(.commission_rate * 100 / 10000)%",
      "Total slashed                : \(.total_slashed)",
      "Conversion ratio             : \(.conversion_ratio)",
      "Registration block           : \(.registration_block)",
      "Jail release block           : \(.jail_release_block)",
      "Validator status             : \(
        .state | 
        if . == 0 then "✅ Active" 
        elif . == 1 then "⏸️ Paused" 
        elif . == 2 then " Jailed" 
        elif . == 3 then " Jailbound" 
        elif . == 4 then " Jailed (Inactivity)" 
        elif . == 5 then " Jailbound (Inactivity)" 
        else "❓ Unknown" 
        end
      )"
    '

  echo -e "\n${BOLD}${BLUE}For more detail, check your validator on the web:${RESET}"
  echo "https://stakeflow.io/autonity-bakerloo/$node_address_lower"
}

main "$@"
