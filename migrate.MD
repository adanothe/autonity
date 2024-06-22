# Migration Guide

## Overview
This guide provides step-by-step instructions on how to migrate autonity validator to new server.

## Prerequisites
Before starting the migration process, make sure you have the following:

- Access to the old validator server
- Access to the new server where you want to migrate the validator
- Necessary permissions and credentials for both servers

## guide

1. **Pause validator, backup validator data, Update enode URL with new IP in the old server**
    - running command here, choose validator migration and input **ip of new server**
    ```bash
    autonity validator setup
    ```
    - Copy the backup data to the new server, the validator data backup in **$HOME/backups**
    - stop node and oracle
    ```
    autonity node stop && autonity oracle stop
    ```
2. **in the New Server**
    - extra all backup data 
    ```
    tar -xvzf backup-keystore_*_*-*-*-*.tar.gz -C ~ && tar -xvzf backup-autonitykeys_*_*-*-*-*.tar.gz -C ~
    ```
    - Install Server Prerequisites & Tools
    ```
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install curl git jq expect fail2ban ufw -y
    ```
    - **input ip of new server and password your key**
    ```
    curl -sO https://raw.githubusercontent.com/adanothe/autonity/main/install.sh && \
    chmod +x install.sh && \
    ```
    
    - start node and oracle
    ```
    autonity node start && autonity oracle start
    ```
    - After your node is synced reactivate the validator 
      to check if your node is synced simply run `autonity node sync`
    - choose 3 to activate validator
      ```
      autonity validator management
      ```

## Conclusion
By following the steps outlined in this guide, you should be able to successfully migrate autonity validator new server. Remember to test thoroughly and monitor the new server to ensure a smooth transition.
