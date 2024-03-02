#!/usr/bin/expect -f

# Define the aut location
set AUT_BIN "/root/.local/bin/aut"
set KEYSTORE_DIR "$env(HOME)/.autonity/keystore"

# Create the keystore folder if it does not exist
exec mkdir -p "$KEYSTORE_DIR"

# Ask the user to enter the password
stty -echo
send_user "Enter the password for the account: "
expect_user -re "(.*)\n"
set PASSWORD $expect_out(1,string)
stty echo
send_user "\n"

# Initialize variables to store addresses
set oracle_address ""
set treasury_address ""

# Check if aut exists at the expected location
if { [file executable $AUT_BIN] } {
    # Run the aut command to create a new account using oracle.key keystore
    spawn "$AUT_BIN" account new -k "$KEYSTORE_DIR/oracle.key"
    expect "Password for new account:"
    send "$PASSWORD\r"
    expect "Confirm account password:"
    send "$PASSWORD\r"
    expect {
        "0x*" {
            set oracle_address $expect_out(0,string)
            exp_continue
        }
    }

    # Run the aut command to create a new account using treasury.key keystore
    spawn "$AUT_BIN" account new -k "$KEYSTORE_DIR/treasury.key"
    expect "Password for new account:"
    send "$PASSWORD\r"
    expect "Confirm account password:"
    send "$PASSWORD\r"
    expect {
        "0x*" {
            set treasury_address $expect_out(0,string)
        }
    }

    # Provide information to the user
    puts "Oracle Address: $oracle_address"
    puts "Treasury Address: $treasury_address"
    puts ""
    puts "Make sure you save these addresses for future use."
} else {
    puts "Aut not found at the expected location."
    exit 1
}
