#!/usr/bin/expect -f

# Define the location of aut
set AUT_BIN [exec which aut]

# Create the keystore folder if it does not exist
set KEYSTORE_DIR "$env(HOME)/.autonity/keystore"
exec mkdir -p "$KEYSTORE_DIR"

# Read the value of KEYPASSWORD from the .env file
set env_file [exec cat /root/autonity/.env]
foreach line [split $env_file \n] {
    if {[regexp {KEYPASSWORD=(.*)} $line -> password]} {
        set KEYPASSWORD $password
        break
    }
}

# Check if aut exists at the expected location
if { $AUT_BIN != "" && [file executable $AUT_BIN] } {
    # Run the aut command to create a new account using oracle.key keystore
    spawn "$AUT_BIN" account new -k "$KEYSTORE_DIR/oracle.key"
    expect "Password for new account:"
    send "$KEYPASSWORD\r"
    expect "Confirm account password:"
    send "$KEYPASSWORD\r"
    expect {
        "0x*" {
            set oracle_address $expect_out(0,string)
            exp_continue
        }
    }

    # Run the aut command to create a new account using treasury.key keystore
    spawn "$AUT_BIN" account new -k "$KEYSTORE_DIR/treasury.key"
    expect "Password for new account:"
    send "$KEYPASSWORD\r"
    expect "Confirm account password:"
    send "$KEYPASSWORD\r"
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
    puts "Aut not found at the expected location or not installed."
    exit 1
}
