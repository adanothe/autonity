# Autonity Piccadilly Testnet Setup

## Resources

- **Official Documentation**: [Autonity Documentation](https://docs.autonity.org/)
- **GitHub Repositories**: [Autonity GitHub](https://github.com/autonity/)
- **Network Explorer**:
  - [Piccadilly](https://piccadilly.autonity.org/)
  - [Bakerloo](https://bakerloo.autonity.org/)
- **Validator Explorer**:
  - [Stakeflow](https://stakeflow.io/autonity-piccadilly)
  - [autland](https://autland.io/)
  - [Daic.capital](https://autonity.daic.capital/)
- **RPC List**: [Chainlist](https://chainlist.org/?testnets=true&search=piccadilly)
- **Tiber task Repositories**: [tiber-task](https://github.com/autonity/tiber-challenge)

---

## Node Installation

### 1. Preparing Server

#### Hardware Requirements

For detailed hardware requirements, refer to [Hardware Requirements](hardware_requirements.md).

### 2. Install Prerequisites

Run the following commands to install the required tools:

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl git jq expect ufw -y
```

Clone this repository and install:

```bash
git clone https://github.com/adanothe/autonity.git
cd autonity
chmod +x install.sh
bash install.sh
```

- During installation, provide the password for wallet.

### 3. Create Wallet

To create a wallet, run the command:
```bash
autonity wallet
```
- Select **"Create Wallet"** and create two wallets named `oracle` and `treasury`.
- Wallets will be saved in the directory `$HOME/.autonity/keystore`.
- Export the private key the `oracle` wallet by choosing **"Export private key from existing wallet"** and selecting `oracle.key`. This key is used for validator registration.

Note:
- **`treasury.key`**: Used for transactions, validator lifecycle, and staking rewards.
- **`oracle.key`**: Used to sign price report transactions sent to the Oracle Contract. Make sure it's funded to avoid gas issues.

If migrating validators from old server, skip the steps above, Simply move the backups of `treasury.key` and `oracle.key` to `$HOME/.autonity/keystore` and `autonitykeys` to `$HOME/autonity-cahindata/autonity`.

When running `autonity wallet` command you will be presented with the following options:
1. **Create new wallet**
2. **Import wallet using private key**
3. **Export private key from existing wallet**
4. **wallet infor**
5. **create signature message**
6. **create signature message with validator key**
7. **Backup wallet**
8. **create transaction**

---

## Running Node

To manage your node, use the following commands:

```bash
autonity node start               # Start the node
autonity node logs                # View node logs
autonity node sync                # Check sync status
autonity node restart             # Restart the node
autonity node info                # Display node info
autonity node stop                # Stop the node
autonity node update              # Update the node
```

---

## Setting Up Oracle Server

### 1. Ensure Node Sync

Check if your node is synced:

```bash
autonity node sync
```

### 2. Fund the Oracle Wallet

Fund oracle wallet (`oracle.key`) wallet with ATN by using the `autonity wallet` command and selecting "create transaction" menu.

### 3. Configure Plugins

Edit the `plugins-conf.yml` file to configure plugins. Obtain API keys from:

- [CurrencyFreaks](https://currencyfreaks.com)
- [OpenExchangeRates](https://openexchangerates.org)
- [CurrencyLayer](https://currencylayer.com)
- [ExchangeRate-API](https://www.exchangerate-api.com)

Edit the configuration:

```bash
nano $HOME/.autonity/oracle/plugins-conf.yml
```

**Example Configuration**:  
![Example Configuration](plugins/photo_2024-12-19_10-13-22.jpg)
---

## Running Oracle Server

To manage the Oracle server, use the following commands:

```bash
autonity oracle start          # Start Oracle server
autonity oracle logs           # View Oracle logs
autonity oracle restart        # Restart Oracle server
autonity oracle stop           # Stop Oracle server
autonity oracle update         # Update Oracle server
```

---

## Manage Validator  

Manage your validator using the following commands:  

```bash  
autonity validator setup          # Validator setup  
autonity validator info           # Display validator information  
autonity validator list           # List all validators  
autonity validator seat active    # Check the list validators in active seats  
```  

When running `autonity validator setup` command you will be presented with the following options:
1. **Create Validator**: Set up a new validator.  
2. **Stake & Unstake Validator**: Manage the staking and unstaking your validator.  
3. **Pause & Reactivate Validator**: Temporarily pause or reactivate your validator.  
4. **Change Commission Validator**: Update the commission rate for your validator.  

---  


## Swap

- Set Up Environment Variables

1. Edit the `.env` file:  
   ```bash
   nano $HOME/autonity/.env
   ```

2. Add your details:  
   ```plaintext
   RPC_URL=your_rpc_url
   SENDER_PRIVATE_KEY=your_private_key
   RECIPIENT_ADDRESS=your_recipient_address
   ```

- Run swap command:  
  ```bash
  autonity swap
  ```

---

### All subcommands autonity

- **`validator`** : Validator management
- **`wallet`**    : Wallet management
- **`node`**      : Node management
- **`oracle`**    : Oracle server management
- **`swap`**      : On-chain swap
- **`help`**      : Display help menu

For more details, run:

```bash
autonity help
```

---