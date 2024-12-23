import logging
import os
import random
import time
from typing import cast

from web3 import Web3, HTTPProvider
from web3.exceptions import ContractLogicError
from web3.middleware import Middleware, SignAndSendRawMiddlewareBuilder

from .tasks import tasks

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("starter_kit")

w3 = Web3(HTTPProvider(os.environ["RPC_URL"]))

sender_account = w3.eth.account.from_key(os.environ["SENDER_PRIVATE_KEY"])

# Set `sender_account` as the sender of all transactions
w3.eth.default_account = sender_account.address

# Set `sender_account` as the signer of all transactions
signer_middleware = cast(
    Middleware, SignAndSendRawMiddlewareBuilder.build(sender_account)
)
w3.middleware_onion.add(signer_middleware)

def execute_tasks():
    for _ in range(10_000):
        task = random.choice(tasks)
        logger.info(task.__name__)
        try:
            task(w3)
        except ContractLogicError as e:
            # Contract execution reverted
            logger.warning(e)

while True:
    execute_tasks()
    time.sleep(3600)  
