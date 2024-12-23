import os
from dotenv import load_dotenv
from web3 import Web3
from starter_kit import params
from starter_kit.bindings.erc20 import ERC20
from starter_kit.bindings.uniswap_v2_router_02 import UniswapV2Router02

load_dotenv()

GAS_LIMIT = 2000000
GAS_PRICE = "5"

def clear_screen():
    os.system("cls" if os.name == "nt" else "clear")

def menu():
    while True:
        clear_screen()
        print("\n===== Actions =====")
        print("1. Swap Tokens")
        print("2. Unwarp WATN to ATN")
        print("3. Exit")
        print("================")

        try:
            choice = int(input("Select menu (1-3): "))
        except ValueError:
            print("Invalid input. Please enter a number.")
            input("Press Enter to return to the menu...")
            continue

        if choice == 1:
            swap_tokens()
        elif choice == 2:
            unwarp_watn_to_atn()
        elif choice == 3:
            print("Exiting........")
            break
        else:
            print("Invalid choice. Please try again.")

        input("Press Enter to return to the menu...")


def init_web3():
    private_key = os.getenv("SENDER_PRIVATE_KEY")
    rpc_url = os.getenv("RPC_URL")
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    if not w3.is_connected():
        print("Web3 not connected!")
        exit(1)
    account = w3.eth.account.from_key(private_key)
    w3.eth.default_account = account.address
    return w3, account


def init_erc20_tokens(w3):
    usdcx = ERC20(w3, params.USDCX_ADDRESS)
    ntn = ERC20(w3, params.NTN_ADDRESS)
    watn = ERC20(w3, params.WATN_ADDRESS)
    uniswap_router = UniswapV2Router02(w3, params.UNISWAP_ROUTER_ADDRESS)
    return usdcx, ntn, watn, uniswap_router


def get_reserve(usdcx, ntn, watn):
    reserve_ntn = ntn.balance_of(params.NTNUSDCX_POOL)
    reserve_usdcx = usdcx.balance_of(params.NTNUSDCX_POOL)
    reserve_watn = watn.balance_of(params.WATNUSDCX_POOL)
    reserve_usdcx_watn = usdcx.balance_of(params.WATNUSDCX_POOL)
    reserve_watn_usdcx = watn.balance_of(params.WATNUSDCX_POOL)
    return (
        reserve_ntn,
        reserve_usdcx,
        reserve_watn,
        reserve_usdcx_watn,
        reserve_watn_usdcx,
    )


def get_price_and_amount(
    token_amount,
    swap_direction,
    uniswap_router,
    reserve_usdcx,
    reserve_ntn,
    reserve_watn,
    reserve_usdcx_watn,
    reserve_watn_usdcx,
    usdcx,
    ntn,
    watn,
):
    if swap_direction == "1":
        quote_result = uniswap_router.quote(token_amount, reserve_usdcx, reserve_ntn)
        token_out = quote_result / 10 ** ntn.decimals()
    elif swap_direction == "2":
        quote_result = uniswap_router.quote(token_amount, reserve_ntn, reserve_usdcx)
        token_out = quote_result / 10 ** usdcx.decimals()
    elif swap_direction == "3":
        quote_result = uniswap_router.quote(
            token_amount, reserve_usdcx_watn, reserve_watn
        )
        token_out = quote_result / 10 ** watn.decimals()
    elif swap_direction == "4":
        quote_result = uniswap_router.quote(
            token_amount, reserve_watn_usdcx, reserve_usdcx
        )
        token_out = quote_result / 10 ** usdcx.decimals()
    else:
        print("Invalid choice!")
        exit(1)
    return token_out


def approve_token(token, amount_in_wei, nonce, w3):
    allowance = token.allowance(w3.eth.default_account, params.UNISWAP_ROUTER_ADDRESS)
    if allowance < amount_in_wei:
        approval_amount = int(1000 * 10 ** token.decimals())
        print(f"Allowance insufficient. Approving {approval_amount}...")
        approve_tx = token.approve(
            params.UNISWAP_ROUTER_ADDRESS, approval_amount
        ).build_transaction(
            {
                "from": w3.eth.default_account,
                "gas": GAS_LIMIT,
                "gasPrice": w3.to_wei(GAS_PRICE, "gwei"),
                "nonce": nonce,
            }
        )
        signed_approve_tx = w3.eth.account.sign_transaction(
            approve_tx, os.getenv("SENDER_PRIVATE_KEY")
        )
        w3.eth.send_raw_transaction(signed_approve_tx.raw_transaction)
        nonce += 1
    return nonce


def approve_and_swap(
    token, amount_in_wei, path, nonce, uniswap_router, w3, account, private_key
):
    nonce = approve_token(token, amount_in_wei, nonce, w3)
    print("Performing swap...")
    swap_tx = uniswap_router.swap_exact_tokens_for_tokens(
        amount_in=amount_in_wei,
        amount_out_min=0,
        path=path,
        to=account.address,
        deadline=w3.eth.get_block("latest").timestamp + 10,
    ).build_transaction(
        {
            "from": w3.eth.default_account,
            "gas": GAS_LIMIT,
            "gasPrice": w3.to_wei(GAS_PRICE, "gwei"),
            "nonce": nonce,
        }
    )
    signed_swap_tx = w3.eth.account.sign_transaction(swap_tx, private_key)
    tx_hash_swap = w3.eth.send_raw_transaction(signed_swap_tx.raw_transaction)
    return tx_hash_swap


def unwarp_function(w3, watn, amount):
    try:
        print(f"Unwarp {amount} WATN to ATN...")
        amount_in_wei = int(amount * 10 ** watn.decimals())
        withdraw_tx = watn.withdraw(amount_in_wei).build_transaction(
            {
                "from": w3.eth.default_account,
                "gas": GAS_LIMIT,
                "gasPrice": w3.to_wei(GAS_PRICE, "gwei"),
                "nonce": w3.eth.get_transaction_count(w3.eth.default_account),
            }
        )
        signed_tx = w3.eth.account.sign_transaction(
            withdraw_tx, os.getenv("SENDER_PRIVATE_KEY")
        )
        tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
        print(
            f"unwarp succeeded! Tx Hash: https://piccadilly.autonity.org/tx/0x{tx_hash.hex()}"
        )
    except Exception as e:
        print(f"errors occured: {e}")


def swap_tokens():
    while True:
        clear_screen()
        w3, account = init_web3()
        usdcx, ntn, watn, uniswap_router = init_erc20_tokens(w3)
        (
            reserve_ntn,
            reserve_usdcx,
            reserve_watn,
            reserve_usdcx_watn,
            reserve_watn_usdcx,
        ) = get_reserve(usdcx, ntn, watn)

        print("\nSelect swap pair:")
        print("1. USDCx/NTN")
        print("2. NTN/USDCx")
        print("3. USDCx/WATN")
        print("4. WATN/USDCx")
        print("5. Exit")

        swap_choice = input("Please select a pair (1-5): ")
        if swap_choice == "1":
            token = usdcx
            path = [params.USDCX_ADDRESS, params.NTN_ADDRESS]
        elif swap_choice == "2":
            token = ntn
            path = [params.NTN_ADDRESS, params.USDCX_ADDRESS]
        elif swap_choice == "3":
            token = usdcx
            path = [params.USDCX_ADDRESS, params.WATN_ADDRESS]
        elif swap_choice == "4":
            token = watn
            path = [params.WATN_ADDRESS, params.USDCX_ADDRESS]
        elif swap_choice == "5":
            break
        else:
            print("Invalid choice!")
            continue

        amount = float(
            input(
                f"Enter the amount of {token.symbol()} you want to swap (e.g., 0.01): "
            )
        )

        if swap_choice in ["1", "3"]:
            amount_in_wei = int(amount * 10 ** usdcx.decimals())
        elif swap_choice in ["2", "4"]:
            amount_in_wei = int(amount * 10 ** token.decimals())

        token_out = get_price_and_amount(
            amount_in_wei,
            swap_choice,
            uniswap_router,
            reserve_usdcx,
            reserve_ntn,
            reserve_watn,
            reserve_usdcx_watn,
            reserve_watn_usdcx,
            usdcx,
            ntn,
            watn,
        )

        symbol = ntn.symbol() if swap_choice in ["1", "2"] else watn.symbol()
        print(f"Amount received: {token_out} {symbol}")

        confirm = input("Do you want to proceed with the transaction? (y/n): ")
        if confirm.lower() == "y":
            nonce = w3.eth.get_transaction_count(w3.eth.default_account)
            try:
                tx_hash_swap = approve_and_swap(
                    token,
                    amount_in_wei,
                    path,
                    nonce,
                    uniswap_router,
                    w3,
                    account,
                    os.getenv("SENDER_PRIVATE_KEY"),
                )
                print(
                    f"Transaction successful: https://piccadilly.autonity.org/tx/0x{tx_hash_swap.hex()}"
                )
            except Exception as e:
                print(f"Error occurred: {e}")
        else:
            print("Transaction canceled.")
        input("Press Enter to return to the pair selection menu...")


def unwarp_watn_to_atn():
    while True:
        clear_screen()
        print("\n===== Unwarp WATN to ATN =====")
        print("1. Unwarp WATN to ATN")
        print("2. Exit")

        choice = input("Select option (1-2): ")

        if choice == "1":
            w3, account = init_web3()
            _, _, watn, _ = init_erc20_tokens(w3)
            amount = float(input("Enter amount WATN to unwarp (e.g., 0.01): "))
            confirm = input(f"Are you sure to unwarp {amount} WATN to ATN? (y/n): ")
            if confirm.lower() == "y":
                unwarp_function(w3, watn, amount)
                input("Unwarp completed! Press Enter to return to unwarp menu...")
                continue
            else:
                print("Unwarp transaction canceled.")
                input("Press Enter to return to unwarp menu...")
                continue
        elif choice == "2":
            break
        else:
            print("Invalid choice! Please select a valid option.")
            input(
                "Press Enter to try again..."
            )  


if __name__ == "__main__":
    menu()
