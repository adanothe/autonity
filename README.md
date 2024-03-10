# Setup Incentivized Testnet Piccadilly Circus Games Competition (PCGC) 

## table of contents
- [Server Prerequisites](#Server-Prerequisites)
- [Install Tools and Start Node](#Install-Tools-and-Start-Node)
  - [Check Node Logs](#Check-Node-Logs)
  - [Check Node Sync](#Check-Node-Sync)
  - [Restart Node](#restart-Node)
  - [Stop Node](#stop-Node)
  - [Update Node](#update-Node)
- [Register for Piccadilly Circus Games Competition](#Register-for-Piccadilly-Circus-Games-Competition)
- [Register Validator](#Register-Validator)
- [setup & Start Oracle Server](#Setup-&-Start-Oracle-Server)
  - [Edit Oracle Server Data Plugins Config File](#Edit-Oracle-Server-Data-Plugins-Config-File)
  - [Start Oracle Server](#Start-Oracle-Server)
  - [Check Oracle Server Logs](#check-Oracle-Server-logs)
  - [Stop Oracle Server](#stop-Oracle-Server)
  - [Restart Oracle Server](#restart-Oracle-Server)
  - [Update Oracle Server](#update-Oracle-Server)
- [Register Validator to PCGC](#Register-Validator-to-PCGC)


## Server Prerequisites
```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl git jq expect fail2ban ufw -y
```

## Install Tools and Start Node
```bash
curl -sO https://raw.githubusercontent.com/adanothe/autonity/main/install.sh && chmod +x install.sh && bash install.sh
```
During installation, you will be asked to set a password for the key wallet. The password will be used to unlock the wallet and sign the transaction. The password you create will be saved in the .env Wallets are automatically created during installation, and keystores are saved in `$HOME/.autonity/keystore`.

There are 2 wallets that were created:
- `treasury.key`: We will use this wallet to register for the game and manage the validator.
- `oracle.key`: This will be used as a cryptographic identifier for the Oracle server and will be used to sign price report transactions sent to the Oracle Contract on-chain.
- `autonitykeys`: 

### Check Node Logs
```bash
autonity node logs
```
### Check Node Sync
```bash
autonity node sync
```
### restart Node
```bash
autonity node restart
```
### stop Node
```bash
autonity node stop
```
### update Node
```bash
autonity node update
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

## Setup & Start Oracle Server
Pre-fund the oracle server account (oracle.key) with ATN, see command to send ATN to the oracle account in documentation [cheatsheet](https://github.com/adanothe/autonity/blob/main/cheatsheet.md#wallet-management).
Edit your oracle server data plugins config file `plugins-conf.yml` to specify the name and key for each plugin you are using. Get the API key on the site below, please register and copy each API key.
- [CurrencyFreaks](https://currencyfreaks.com)
- [OpenExchangeRates](https://openexchangerates.org)
- [CurrencyLayer](https://currencylayer.com)
- [ExchangeRate-API](https://www.exchangerate-api.com)
```bash
nano $HOME/.autonity/oracle/plugins-conf.yml
```
![Tempsnip](https://github.com/adanothe/autonity/blob/main/plugins/IMG_20240310_171734.png)

### Start Oracle Server
```bash
autonity oracle start
```
### check Oracle Server logs
```bash
autonity oracle logs
```
### stop Oracle Server
```bash
autonity oracle stop
```
### restart Oracle Server
```bash
autonity oracle restart
```
### update Oracle Server
```bash
autonity oracle update
```

## Register Validator to PCGC
Registration Link: [Register Validator](https://game.autonity.org/awards/register-validator.html)

Run this command to get signature and enode:
```bash
autonity wallet management
```
Choose option 2, to Create Signature and enode for validator registration.

## bond to your validator
```bash
autonity validator setup
```
choose option 2 to bond to your validator.

to see more commands check cheatsheet [cheatsheet](https://github.com/adanothe/autonity/blob/main/cheatsheet.md#wallet-management), or run the command below:
```bash
autonity help
```
--- 
