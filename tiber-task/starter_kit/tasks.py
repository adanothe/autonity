from typing import Callable, List, TypeAlias, cast

from autonity import Autonity
from eth_typing import ChecksumAddress
from web3 import Web3
from web3.types import TxParams

from . import params
from .bindings.erc20 import ERC20
from .bindings.uniswap_v2_factory import UniswapV2Factory
from .bindings.uniswap_v2_router_02 import UniswapV2Router02

Task: TypeAlias = Callable[[Web3], None]

tasks: List[Task] = []

GAS_LIMIT = 2000000
GAS_PRICE = "3"  # Gwei


def get_nonce(w3: Web3) -> int:
    return w3.eth.get_transaction_count(w3.eth.default_account)


def transfer(w3: Web3) -> None:
    """Transfers 0.01 NTN to a recipient specified in .env."""
    autonity = Autonity(w3)
    amount = int(0.01 * 10 ** autonity.decimals())
    tx_params = {
        "gas": GAS_LIMIT,
        "gasPrice": w3.to_wei(GAS_PRICE, "gwei"),
        "nonce": get_nonce(w3),
    }
    tx = autonity.transfer(params.RECIPIENT_ADDRESS, amount).transact(tx_params)
    w3.eth.wait_for_transaction_receipt(tx)


tasks.append(transfer)


def bond(w3: Web3) -> None:
    """Bonds 0.01 NTN to the first validator."""
    autonity = Autonity(w3)
    validator_address = autonity.get_validators()[0]
    amount = int(0.01 * 10 ** autonity.decimals())
    tx_params = {
        "gas": GAS_LIMIT,
        "gasPrice": w3.to_wei(GAS_PRICE, "gwei"),
        "nonce": get_nonce(w3),
    }
    tx = autonity.bond(validator_address, amount).transact(tx_params)
    w3.eth.wait_for_transaction_receipt(tx)


tasks.append(bond)


def unbond(w3: Web3) -> None:
    """Unbonds 0.01 NTN from the first validator."""
    autonity = Autonity(w3)
    validator_address = autonity.get_validators()[0]
    amount = int(0.01 * 10 ** autonity.decimals())
    tx_params = {
        "gas": GAS_LIMIT,
        "gasPrice": w3.to_wei(GAS_PRICE, "gwei"),
        "nonce": get_nonce(w3),
    }
    tx = autonity.unbond(validator_address, amount).transact(tx_params)
    w3.eth.wait_for_transaction_receipt(tx)


tasks.append(unbond)


def approve(w3: Web3) -> None:
    """Approves the transfer of 0.01 NTN by a recipient specified in .env."""
    autonity = Autonity(w3)
    amount = int(0.01 * 10 ** autonity.decimals())
    erc20 = ERC20(w3, params.NTN_ADDRESS)
    current_allowance = erc20.allowance(
        w3.eth.default_account, params.RECIPIENT_ADDRESS
    )

    if current_allowance < amount:
        tx_params = {
            "gas": GAS_LIMIT,
            "gasPrice": w3.to_wei(GAS_PRICE, "gwei"),
            "nonce": get_nonce(w3),
        }
        tx = autonity.approve(params.RECIPIENT_ADDRESS, amount).transact(tx_params)
        w3.eth.wait_for_transaction_receipt(tx)


tasks.append(approve)


def swap_exact_tokens_for_tokens(w3: Web3) -> None:
    """Swaps 0.01 NTN for USDCx."""
    ntn = ERC20(w3, params.NTN_ADDRESS)
    ntn_amount = int(0.01 * 10 ** ntn.decimals())
    current_allowance = ntn.allowance(
        w3.eth.default_account, params.UNISWAP_ROUTER_ADDRESS
    )

    if current_allowance < ntn_amount:
        approve_tx = ntn.approve(params.UNISWAP_ROUTER_ADDRESS, ntn_amount).transact()
        w3.eth.wait_for_transaction_receipt(approve_tx)

    uniswap_router = UniswapV2Router02(w3, params.UNISWAP_ROUTER_ADDRESS)
    sender_address = cast(ChecksumAddress, w3.eth.default_account)
    deadline = w3.eth.get_block("latest").timestamp + 10  # type: ignore
    swap_tx = uniswap_router.swap_exact_tokens_for_tokens(
        amount_in=ntn_amount,
        amount_out_min=0,
        path=[params.NTN_ADDRESS, params.USDCX_ADDRESS],
        to=sender_address,
        deadline=deadline,
    ).transact()
    w3.eth.wait_for_transaction_receipt(swap_tx)


tasks.append(swap_exact_tokens_for_tokens)


def swap_exact_atn_for_ntn(w3: Web3) -> None:
    """Swaps 0.01 ATN for NTN."""
    watn = ERC20(w3, params.WATN_ADDRESS)
    atn_amount = int(0.01 * 10 ** watn.decimals())
    current_allowance = watn.allowance(
        w3.eth.default_account, params.UNISWAP_ROUTER_ADDRESS
    )

    if current_allowance < atn_amount:
        approve_tx = watn.approve(params.UNISWAP_ROUTER_ADDRESS, atn_amount).transact()
        w3.eth.wait_for_transaction_receipt(approve_tx)

    uniswap_router = UniswapV2Router02(w3, params.UNISWAP_ROUTER_ADDRESS)
    sender_address = cast(ChecksumAddress, w3.eth.default_account)
    deadline = w3.eth.get_block("latest").timestamp + 10  # type: ignore
    swap_tx = uniswap_router.swap_exact_eth_for_tokens(
        amount_out_min=0,
        path=[params.WATN_ADDRESS, params.NTN_ADDRESS],
        to=sender_address,
        deadline=deadline,
    ).transact(cast(TxParams, {"value": atn_amount}))
    w3.eth.wait_for_transaction_receipt(swap_tx)


tasks.append(swap_exact_atn_for_ntn)


def add_liquidity(w3: Web3) -> None:
    """Adds 0.1 NTN and 0.133459 USDCx to the Uniswap liquidity pool."""

    ntn = ERC20(w3, params.NTN_ADDRESS)
    ntn_amount = int(0.1 * 10 ** ntn.decimals())
    current_allowance = ntn.allowance(
        w3.eth.default_account, params.UNISWAP_ROUTER_ADDRESS
    )
    if current_allowance < ntn_amount:
        approve_tx_2 = ntn.approve(params.UNISWAP_ROUTER_ADDRESS, ntn_amount).transact()
        w3.eth.wait_for_transaction_receipt(approve_tx_2)

    usdc = ERC20(w3, params.USDCX_ADDRESS)
    usdc_amount = int(0.133459 * 10 ** usdc.decimals())
    current_allowance = usdc.allowance(
        w3.eth.default_account, params.UNISWAP_ROUTER_ADDRESS
    )
    if current_allowance < usdc_amount:
        approve_tx_1 = usdc.approve(
            params.UNISWAP_ROUTER_ADDRESS, usdc_amount
        ).transact()
        w3.eth.wait_for_transaction_receipt(approve_tx_1)

    uniswap_router = UniswapV2Router02(w3, params.UNISWAP_ROUTER_ADDRESS)
    sender_address = cast(ChecksumAddress, w3.eth.default_account)
    deadline = w3.eth.get_block("latest").timestamp + 10  # type: ignore

    add_liquidity_tx = uniswap_router.add_liquidity(
        token_a=params.NTN_ADDRESS,
        token_b=params.USDCX_ADDRESS,
        amount_a_desired=ntn_amount,
        amount_b_desired=usdc_amount,
        amount_a_min=0,
        amount_b_min=0,
        to=sender_address,
        deadline=deadline,
    ).transact()

    w3.eth.wait_for_transaction_receipt(add_liquidity_tx)


tasks.append(add_liquidity)


def remove_liquidity(w3: Web3) -> None:
    """Removes all funds from the Uniswap liquidity pool."""
    uniswap_factory = UniswapV2Factory(w3, params.UNISWAP_FACTORY_ADDRESS)
    ntn_usdc_pair_address = uniswap_factory.get_pair(
        params.NTN_ADDRESS, params.USDCX_ADDRESS
    )

    uniswap_ntn_usdc_pair = ERC20(w3, ntn_usdc_pair_address)
    sender_address = cast(ChecksumAddress, w3.eth.default_account)
    liquidity_amount = uniswap_ntn_usdc_pair.balance_of(sender_address)

    if liquidity_amount > 0:
        approve_tx = uniswap_ntn_usdc_pair.approve(
            params.UNISWAP_ROUTER_ADDRESS, liquidity_amount
        ).transact()
        w3.eth.wait_for_transaction_receipt(approve_tx)

        uniswap_router = UniswapV2Router02(w3, params.UNISWAP_ROUTER_ADDRESS)
        deadline = w3.eth.get_block("latest").timestamp + 10  # type: ignore
        remove_liquidity_tx = uniswap_router.remove_liquidity(
            token_a=params.NTN_ADDRESS,
            token_b=params.USDCX_ADDRESS,
            liquidity=liquidity_amount,
            amount_a_min=0,
            amount_b_min=0,
            to=sender_address,
            deadline=deadline,
        ).transact()
        w3.eth.wait_for_transaction_receipt(remove_liquidity_tx)


tasks.append(remove_liquidity)
