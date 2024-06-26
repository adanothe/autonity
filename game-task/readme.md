# PCGC Task

## Open the Door Challenge

### Requirements & Details
- You must use a separate machine or server from the main node.
- There will be a maximum of 50 winners for this challenge.

### guide
- install & get data for registration task

```sh
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl git jq expect fail2ban ufw -y
```

```sh
curl -sO https://raw.githubusercontent.com/adanothe/autonity/main/game-task/rpc.sh && \
chmod +x rpc.sh && \
bash rpc.sh 
```

- registration form [open the door](https://game.autonity.org/awards/register-node.html)


## PnL Challenge
> Points are earned for levels of transaction activity and trading profit

### Bridge mock USDC from Amoy to Piccadilly
- import your registered account address into your wallet
  ```sh
  autonity wallet import
  ```
- navigate to the [mock USDC Bridge](https://usdc-frontend-autonity.vercel.app/) Connect your wallet and execute the bridge transfer

### Trading with your mock USDC on Piccadilly
- [Create cax apikey](https://github.com/adanothe/autonity#using-cax)
- To trade off-chain in the CAX you will need to deposit your bridged mock USDC to the exchange
  choose USDC send to Exchange address: `0x11F62c273dD23dbe4D1713C5629fc35713Aa5a94`
  ```sh
  autonity wallet tx
  ```
- 

  
