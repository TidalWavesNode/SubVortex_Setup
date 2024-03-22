#!/bin/bash

# Function to display a countdown
countdown() {
    local count=$1
    while [ $count -gt 0 ]; do
        echo -ne "$count seconds remaining\033[0K\r"
        sleep 1
        ((count--))
    done
}

# Function to install SubVortex
install_subvortex() {
    echo "Installing SubVortex"
    countdown 3
    sudo apt update && sudo apt upgrade -y || { echo "Failed to update packages"; exit 1; }
    sudo apt install git nodejs npm expect -y || { echo "Failed to install required packages"; exit 1; }
    sudo npm i -g pm2 || { echo "Failed to install pm2"; exit 1; }
    sudo apt install python3-pip -y || { echo "Failed to install python3-pip"; exit 1; }
    cd "$HOME" || exit
    git clone https://github.com/eclipsevortex/SubVortex.git || { echo "Failed to clone SubVortex repository"; exit 1; }
    cd SubVortex || { echo "SubVortex directory not found"; exit 1; }
    sleep 2
    echo "Installing Dependencies"
    countdown 3
    pip install -r requirements.txt || { echo "Failed to install Python dependencies"; exit 1; }
    pip install -e . || { echo "Failed to install SubVortex"; exit 1; }
}

# Function to install and start Subtensor using pm2
install_and_start_subtensor() {
    local network=$1
    local network_arg

    # Determine the appropriate argument based on the network UID
    if [ "$network" == "XX" ]; then  # Replace XX with the actual UID for mainnet
        network_arg="mainnet"
    elif [ "$network" == "92" ]; then
        network_arg="testnet"
    else
        echo "Invalid network UID."
        exit 1
    fi

    echo "Installing Local Subtensor on $network_arg"
    countdown 3
    cd "$HOME/SubVortex/scripts/subtensor/" || { echo "Subtensor directory not found"; exit 1; }
    ./setup.sh "$network_arg" binary "$HOME" || { echo "Failed to setup Subtensor"; exit 1; }
    echo "Starting Local Subtensor with pm2..."
    countdown 3
    pm2 start start.sh --name "subtensor_$network_arg" -- "$network_arg" binary "$HOME" || { echo "Failed to start Subtensor with pm2"; exit 1; }
    pm2 save || { echo "Failed to save pm2 configuration"; exit 1; }
    echo "Subtensor is now running in the background managed by pm2."
}

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt=$1
    local yn
    read -p "$prompt (yes/y or no/n): " yn
    case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes/y or no/n."; prompt_yes_no "$prompt";;
    esac
}

# Function to start the miner
start_miner() {
    local network=$1
    local WALLETNAME=$2
    local HOTKEY=$3
    local MINERNAME=$4
    echo "Starting Miner... Remember to Register your hotkey on network $network"
    countdown 5
    cd "$HOME/SubVortex/" || exit
    
    # Use expect to interact with btcli command for new_coldkey
    coldkey_output=$(expect -c "
        spawn btcli w new_coldkey >/dev/null
        expect \"The mnemonic to the new coldkey is:\"
        set coldkey_output \$expect_out(buffer)
        puts \$coldkey_output
        expect eof
    ")

    # Append output to WALLETBACKUP file for new_coldkey
    echo "Creating a new ColdWallet..." >> "$WALLETBACKUP"
    echo "$coldkey_output" >> "$WALLETBACKUP"

    # Use expect to interact with btcli command for new_hotkey
    hotkey_output=$(expect -c "
        spawn btcli w new_hotkey >/dev/null
        expect \"The mnemonic to the new hotkey is:\"
        set hotkey_output \$expect_out(buffer)
        puts \$hotkey_output
        expect eof
    ")

    # Append output to WALLETBACKUP file for new_hotkey
    echo "Creating a new HotKey..." >> "$WALLETBACKUP"
    echo "$hotkey_output" >> "$WALLETBACKUP"

    pm2 start neurons/miner.py --name "$MINERNAME" --interpreter python3 -- --netuid "$network" --subtensor.network local --wallet.name "$WALLETNAME" --wallet.hotkey "$HOTKEY" --logging.debug || { echo "Failed to start miner"; exit 1; }
}

# Define the wallet backup file path
WALLETBACKUP="$HOME/WALLETBACKUP.txt"

# Clear the WALLETBACKUP file or create it if it doesn't exist
> "$WALLETBACKUP"

# Main installation process
install_subvortex

# Ask for network type
read -p "Do you want to install subtensor on mainnet or testnet? " network_type
if [ "$network_type" == "mainnet" ]; then
    network="XX" # Replace XX with the actual UID for mainnet when known
    install_and_start_subtensor "$network"
elif [ "$network_type" == "testnet" ]; then
    network="92"
    install_and_start_subtensor "$network"
else
    echo "Invalid network type selected."
    exit 1
fi

# Prompt for ColdWallet creation
if prompt_yes_no "Do you want to create a new ColdWallet?"; then
    # Call start_miner function
    start_miner "$network" "$WALLETNAME" "$HOTKEY" "$MINERNAME"
fi

# Prompt for HotKey creation
if prompt_yes_no "Do you want to create a new HotKey?"; then
    # Call start_miner function
    start_miner "$network" "$WALLETNAME" "$HOTKEY" "$MINERNAME"
fi

# Prompt for starting miner
if prompt_yes_no "Do you want to start miner?"; then
    # Prompt for WALLETNAME
    read -p "Please enter WALLETNAME: " WALLETNAME
    # Prompt for HOTKEYNAME
    read -p "Please enter HOTKEYNAME: " HOTKEY
    # Prompt for MINERNAME
    read -p "Please enter miner name: " MINERNAME
    # Call start_miner function
    start_miner "$network" "$WALLETNAME" "$HOTKEY" "$MINERNAME"
fi
