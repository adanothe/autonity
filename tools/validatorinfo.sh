#!/bin/bash

node_address=$(aut validator info | jq -r '.node_address' | tr '[:upper:]' '[:lower:]')

aut validator info | jq -r '
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
  "Registration block           : \(.registration_block)",
  "Jail release block           : \(.jail_release_block)",
  "Validator status             : \(
    .state | 
    if . == 0 then "active" 
    elif . == 1 then "paused" 
    elif . == 2 then "jailed" 
    elif . == 3 then "jailbound" 
    elif . == 4 then "jailed for inactivity" 
    elif . == 5 then "jailbound for inactivity" 
    else "unknown" 
    end
  )"
'

echo -e "\n\033[1;34mFor more detail your validator check on the website\033[0m"
echo -e "https://stakeflow.io/autonity-piccadilly/validators/$node_address"
