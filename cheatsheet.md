# Cli Cheatsheet

## Table of Contents

- [Validator Management](#validator-management)
  - [setup](#setup)
  - [info](#info)
  - [list](#list)
  - [seat active](#seat-active)
  - [committe](#committe)
  - [help](#help)
- [Wallet Management](#wallet-management)
  - [management](#management)
  - [info](#info-1)
  - [list](#list-1)
  - [help](#help-1)
- [Node Management](#node-management)
  - [start](#start)
  - [logs](#logs)
  - [epoch](#epoch)
  - [sync](#sync)
  - [stop](#stop)
  - [restart](#restart)
  - [help](#help-2)
- [Oracle Management](#oracle-management)
  - [start](#start-1)
  - [logs](#logs-1)
  - [stop](#stop-1)
  - [restart](#restart-1)
  - [update](#update)
  - [help](#help-3)
- [Help](#help-4)

## Validator Management

### setup

Command: `autonity validator setup`

Description: This command allows you to set up a validator. It presents a menu with the following options:
1. Create Validator
2. Bond/Unbond Validator
3. Pause/Reactivate Validator

You will be prompted to enter your choice, and the corresponding script will be executed based on your selection.

### info

Command: `autonity validator info`

Description: This command displays information about the validator.

### list

Command: `autonity validator list`

Description: This command lists all the validators in the Autonity network.

### seat active

Command: `autonity validator seat active`

Description: This command displays the list of active validators in the Autonity network.

### committe

Command: `autonity validator committe`

Description: This command checks if your validator is in the active seat.

### help

Command: `autonity validator help`

Description: This command displays the help menu for the validator commands.

## Wallet Management

### management

Command: `autonity wallet management`

Description: This command provides a menu for managing wallets. It presents the following options:
1. Create Signature registration for game
2. Create Signature for Validator onboarded
3. Create transaction
4. Create wallet

You will be prompted to enter your choice, and the corresponding script will be executed based on your selection.

### info

Command: `autonity wallet info`

Description: This command displays information about the Oracle and Treasury wallets.

### list

Command: `autonity wallet list`

Description: This command lists all the wallets in the Autonity network.

### help

Command: `autonity wallet help`

Description: This command displays the help menu for the wallet commands.

## Node Management

### start

Command: `autonity node start`

Description: This command starts the Autonity node.

### logs

Command: `autonity node logs`

Description: This command displays the logs of the Autonity node.

### epoch

Command: `autonity node epoch`

Description: This command displays the current epoch of the Autonity node.

### sync

Command: `autonity node sync`

Description: This command displays the sync status of the Autonity node.

### stop

Command: `autonity node stop`

Description: This command stops the Autonity node.

### restart

Command: `autonity node restart`

Description: This command restarts the Autonity node.

### help

Command: `autonity node help`

Description: This command displays the help menu for the node commands.

## Oracle Management

### start

Command: `autonity oracle start`

Description: This command starts the Oracle server.

### logs

Command: `autonity oracle logs`

Description: This command displays the logs of the Oracle server.

### stop

Command: `autonity oracle stop`

Description: This command stops the Oracle server.

### restart

Command: `autonity oracle restart`

Description: This command restarts the Oracle server.

### update

Command: `autonity oracle update`

Description: This command updates the Oracle server.

### help

Command: `autonity oracle help`

Description: This command displays the help menu for the oracle commands.

## Help

Command: `autonity help`

Description: This command displays the help menu for all available commands.
