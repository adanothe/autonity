### Registration

To enter the Tiber Challenge, complete the registration form at [Tiber Challenge Registration](http://tiber.autonity.org/). After registering, your participant's Registered Address will be funded with the following:

| Asset                                   | Amount           |
|-----------------------------------------|------------------|
| ATN on Piccadilly                       | 1                |
| NTN on Piccadilly                       | 0                |
| Test USDCx on Piccadilly                | 1000             |
| Test USDC on Polygon Amoy Testnet       | 25               |
| Test POL on Polygon Amoy Testnet       | 0.01             |

For more details about the challenge, please visit the [Tiber Repository](https://github.com/autonity/tiber-challenge).

### Terms and Conditions
The challenge's terms and conditions can be found [here](https://gateway.pinata.cloud/ipfs/Qmcdza1BscJFAr2ubkJ2WEksqG8e3gc3XAVpwR83xNY39g).

### manual Installation Guide for Use-case Testing task

#### 1. Set Up Virtual Environment (Recommended)
To ensure that the dependencies for this challenge do not interfere with other projects, it's recommended to use a virtual environment.

#### 3. Install Dependencies
Once the virtual environment is activated, you need to install the required dependencies:
```bash
pip install -r requirements.txt
```

#### 4. Set Up Environment Variables
You need to create an `.env` file with the following variables:

```plaintext
RPC_URL=your_rpc_url
SENDER_PRIVATE_KEY=your_private_key
RECIPIENT_ADDRESS=your_recipient_address
```

#### 5. Running Scripts

- **Swap Script**  
  To execute the swap script, use the following command:
  ```bash
  python3 swap.py
  ```

- **Task Onchain Script**  
  To execute the task on-chain script, use this command:
  ```bash
  python3 -m starter_kit.main
  ```
