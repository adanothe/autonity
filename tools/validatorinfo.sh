#!/bin/bash

AUT=$(command -v aut)
node_address=$( $AUT validator info | jq -r '.node_address' | tr '[:upper:]' '[:lower:]' )

$AUT validator info | jq -r '
  "Treasury address   : \(.treasury)",
  "Node address       : \(.node_address)",
  "Oracle address     : \(.oracle_address)",
  "Enode              : \(.enode)",
  "Consensus key      : \(.consensus_key)",
  "Bonded stake       : \(.bonded_stake / 1e18) NTN",
  "Self bonded stake  : \(.self_bonded_stake / 1e18) NTN",
  "Commission rate    : \(.commission_rate * 100 / 10000)%", 
  "Total slashed      : \(.total_slashed)",
  "Jail release block : \(.jail_release_block)",
  "Validator status   : \(.state | if . == 0 then "active" elif . == 1 then "paused" elif . == 2 then "jailed" else "unknown" end)"
'

echo -e "\n\033[1;34mFor more detail your validator check on the website\033[0m"
echo -e "https://<soon>/validators/$node_address"
echo -e "https://stakeflow.io/autonity-piccadilly/validators/$node_address"
echo -e "https://autonity.daic.capital/Home/ValidatorDetails?nodeaddress=$node_address"
