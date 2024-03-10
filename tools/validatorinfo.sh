#!/bin/bash

AUT=$(which aut)

$AUT validator info | jq -r '
  "Treasury address   : \(.treasury)",
  "node address       : \(.node_address)",
  "oracle address     : \(.oracle_address)",
  "enode              : \(.enode)",
  "bonded stake       : \(.bonded_stake / 1e18 | floor)",
  "self bonded stake  : \(.self_bonded_stake / 1e18 | floor)",
  "total slashed      : \(.total_slashed)",
  "jail release block : \(.jail_release_block)",
  "validator status   : \(.state | if . == 0 then "active" elif . == 1 then "paused" elif . == 2 then "jailed" else "unknown" end)"
'
