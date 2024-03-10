### Setup Incentivized Testnet Piccadilly Circus Games Competition (PCGC) 
During installation, you will be asked to set a password for the key wallet. The password will be used to unlock the wallet and sign the transaction. The password you create will be saved in the .env Wallets are automatically created during installation, and keystores are saved in `$HOME/.autonity/keystore`.

There are 2 wallets that were created:
- `treasury.key`: We will use this wallet to register for the game and manage the validator.
- `oracle.key`: This will be used as a cryptographic identifier for the Oracle server and will be used to sign price report transactions sent to the Oracle Contract on-chain.

There is also an `autonitykeys` file:
- The private/public key pair of the validator node.
    - The private key is used:
        - By a node for negotiating an authenticated and encrypted connection between other network nodes at the devp2p layer in the RLPx Transport Protocol.
        - To generate the proof of enode ownership required for validator registration. The proof is generated using the `genEnodeProof` command-line option of the Autonity Go Client.
    - The public key is used:
        - As the identifier or 'node ID' of the node (in RLPx and node discovery protocols).
        - As the PUBKEY component of the enode URL as a hex string.
        - To verify the signature of consensus level network messages.
        - To derive an Ethereum format account that is then used to identify the validator node. See validator identifier.

# table of contents
1. [Server Prerequisites](#server-prerequisites)
2. [Install Tools and Start Node](#install-tools-and-start-node)
3. [Check Node Logs](#check-node-logs)
4. [Check Node Sync](#check-node-sync)
5. [Register for Piccadilly Circus Games Competition](#register-for-piccadilly-circus-games-competition)
6. [Register Validator](#register-validator)
7. [Setup Oracle Server](#setup-oracle-server)
8. [Start Oracle Server](#start-oracle-server)
9. [Register Validator to PCGC](#register-validator-to-pcgc)

## Server Prerequisites
```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl git jq expect fail2ban ufw -y
```

## Install Tools and Start Node
```bash
curl --proto '=https' --tlsv1.2 sSfL https://raw.githubusercontent.com/adanothe/autonity/main/install.sh | sudo bash
```

# Check Node Logs
```bash
autonity node logs
```

# Check Node Sync
```bash
autonity node sync
```

## Register for Piccadilly Circus Games Competition
Registration Link: [Piccadilly Circus Games Competition Registration](https://game.autonity.org/getting-started/register.html)

Run this command to get autonity address and signature:
```bash
autonity wallet management
```
Choose option 1, to Create Signature registration for the game. After registering, your registered autonity address will receive 1 ATN and 1 NTN faucet.

## Register Validator
To register as a validator, run the following command:
```bash 
autonity validator setup
```
Choose option 1 to register as a validator.

# Setup Oracle Server
Edit your oracle server data plugins config file `plugins-conf.yml` to specify the name and key for each plugin you are using. Get the API key on the site below, please register and copy each API key.
- [CurrencyFreaks](https://currencyfreaks.com)
- [OpenExchangeRates](https://openexchangerates.org)
- [CurrencyLayer](https://currencylayer.com)
- [ExchangeRate-API](https://www.exchangerate-api.com)
```bash
nano $HOME/.autonity/oracle/plugins-conf.yml
```
![Tempsnip](https://github.com/adanothe/autonity/blob/main/plugins/tempsnip.png)

# Start Oracle Server
```bash
autonity oracle start
```

# Register Validator to PCGC
Registration Link: [Register Validator](https://game.autonity.org/awards/register-validator.html)

Run this command to get signature and enode:
```bash
autonity wallet management
```
Choose option 2, to Create Signature and enode for validator registration.

--- 
