#!/bin/bash

AUT=$(which aut)

$AUT validator info | jq -r '
  "Treasury address   : \(.treasury)",
  "Node address       : \(.node_address)",
  "Oracle address     : \(.oracle_address)",
  "Enode              : \(.enode)",
  "Bonded stake       : \(.bonded_stake / 1e18)",
  "Self bonded stake  : \(.self_bonded_stake / 1e18)",
  "Total slashed      : \(.total_slashed)",
  "Jail release block : \(.jail_release_block)",
  "Validator status   : \(.state | if . == 0 then "active" elif . == 1 then "paused" elif . == 2 then "jailed" else "unknown" end)"
'
