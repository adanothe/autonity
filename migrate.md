# validator migration
### Prerequisites

Before starting the migration process, ensure you have the following:
- Access to the old validator server
- Access to the new server where you want to migrate the validator
- Necessary permissions and credentials for both servers

### Migration Steps

#### Pause Validator and Backup Data on Old Server
1.  Pause the validator, backup the validator data, and update the enode URL with the new IP on the old server:
    - Run the following command, choose "validator migration," and input the IP of the new server:

    ```bash
    autonity validator setup
    ```
    - Copy the backup data located in `$HOME/backups` to the new server.

2.  Stop the node and oracle:
    ```bash
    autonity node stop && autonity oracle stop
    ```

#### Set Up the New Server
1.  Extract all backup data:
    ```bash
    tar -xvzf backup-keystore_*_*-*-*-*.tar.gz -C ~ && tar -xvzf backup-autonitykeys_*_*-*-*-*.tar.gz -C ~
    ```

2.  Install server prerequisites and tools:
    ```bash
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install curl git jq expect fail2ban ufw -y
    ```

3.  Input the password for your key & validator address:
    ```bash
    curl -sO https://raw.githubusercontent.com/adanothe/autonity/main/install.sh && \
    chmod +x install.sh && ./install.sh
    ```

4.  Start the node and oracle:
    ```bash
    autonity node start && autonity oracle start
    ```

5.  After your node is synced, reactivate the validator. To check if your node is synced, run:
    ```bash
    autonity node sync
    ```

6.  Reactivate the validator by choosing option 3:
    ```bash
    autonity validator setup
    ```
