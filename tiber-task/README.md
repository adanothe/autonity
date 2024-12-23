### manual Installation Guide for Use-case Testing

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
