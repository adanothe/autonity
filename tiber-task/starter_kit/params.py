import os
from typing import cast

from autonity.constants import AUTONITY_CONTRACT_ADDRESS
from eth_typing import ChecksumAddress
from web3 import Web3

NTN_ADDRESS = AUTONITY_CONTRACT_ADDRESS
USDCX_ADDRESS = cast(ChecksumAddress, "0xB855D5e83363A4494e09f0Bb3152A70d3f161940")
WATN_ADDRESS = cast(ChecksumAddress, "0xcE17e51cE4F0417A1aB31a3c5d6831ff3BbFa1d2")
NTNUSDCX_POOL = cast(ChecksumAddress, "0xCaf123B55375e3ce1f20368d605086B5b0B767Ed")
WATNUSDCX_POOL= cast(ChecksumAddress, "0x2073d57CAe6642223876Ba3bF56868CC736D977c")

UNISWAP_ROUTER_ADDRESS = cast(
    ChecksumAddress, "0x374B9eacA19203ACE83EF549C16890f545A1237b"
)
UNISWAP_FACTORY_ADDRESS = cast(
    ChecksumAddress, "0x218F76e357594C82Cc29A88B90dd67b180827c88"
)

RECIPIENT_ADDRESS = Web3.to_checksum_address(os.environ["RECIPIENT_ADDRESS"])
