# Setup Incentivized Testnet Piccadilly Circus Games Competition (PCGC) 

## Server prerequisites
```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl git jq expect fail2ban ufw -y
```

## Install tools and start node
```bash
curl --proto '=https' --tlsv1.2 sSfL https://raw.githubusercontent.com/adanothe/autonity/main/install.sh | sudo bash
```
# check node logs
```bash
autonity node logs
```
# check node sync
```bash
autonity node sync
```

## Register piccadilly circus games competition
Register link: [Piccadilly Circus Games Competition Registration](https://game.autonity.org/getting-started/register.html)

Run this command to get autonity address and signature:
```bash
autonity wallet management
```
Choose option Create Signature registration for game. After registering, your registered autonity address will get 1 ATN and 1 NTN faucet.

## Register validator
to register as a validator run the following command:
```bash 
autonity validator setup
```
choose option 1 to register as a validator. 

# start oracle server
edit your oracle server data plugins config file plugins-conf.yml to specify the name and key for each plugins you are using.
we get apikey on the site below, please register and copy each apikey.
- [CurrencyFreaks](https://currencyfreaks.com)
- [OpenExchangeRates](https://openexchangerates.org)
- [CurrencyLayer](https://currencylayer.com)
- [ExchangeRate-API](https://www.exchangerate-api.com)
```bash
nano $HOME/.autonity/oracle/plugins-conf.yml
```
example





















