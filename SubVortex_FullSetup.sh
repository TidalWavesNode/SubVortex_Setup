#!/bin/bash

# Function to display a countdown
countdown() {
    local count=$1
    while [ $count -gt 0 ]; do
        echo -ne "$count\033[0K\r"
        sleep 1
        ((count--))
    done
}

# Function to install SubVortex
install_subvortex() {
    echo "Installing SubVortex"
    countdown 3
    sudo apt update && sudo apt upgrade -y
    sudo apt install git nodejs npm -y
    sudo npm i -g pm2
    sudo apt install python3-pip -y
    cd $HOME
    git clone https://github.com/eclipsevortex/SubVortex.git
    cd SubVortex
    sleep 2
    echo "Installing Dependencies"
    countdown 3
    pip install -r requirements.txt
    pip install -e .
}

# Function to install and start Subtensor
install_and_start_subtensor() {
    local network=$1
    echo "Installing Local Subtensor on $network"
    countdown 3
    cd $HOME
    $HOME/SubVortex/scripts/subtensor/setup.sh $network binary $HOME
    echo "Starting Local Subtensor..."
    countdown 3
    $HOME/SubVortex/scripts/subtensor/start.sh $network binary $HOME
}

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt=$1
    local yn
    read -p "$prompt (yes, y or no, n): " yn
    case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes or no."; prompt_yes_no "$prompt";;
    esac
}

# Function to start the miner
start_miner() {
    local network=$1
    local WALLETNAME=$2
    local HOTKEY=$3
    local MINERNAME=$4
    echo "Starting Miner...Remember to Register your hotkey on network $network"
    countdown 5
    cd $HOME/SubVortex/
    pm2 start neurons/miner.py --name "$MINERNAME" --interpreter python3 -- --netuid "$network" --subtensor.network local --wallet.name "$WALLETNAME" --wallet.hotkey "$HOTKEY" --logging.debug
}

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
    btcli w new_coldkey
fi

# Prompt for HotKey creation
if prompt_yes_no "Do you want to create a new HotKey?"; then
    btcli w new_hotkey
fi

# Prompt for starting miner
if prompt_yes_no "Do you want to start miner?"; then
    # Prompt for WALLETNAME
    echo "Please enter WALLETNAME: "
    read WALLETNAME
    # Prompt for HOTKEYNAME
    echo "Please enter HOTKEYNAME: "
    read HOTKEY
    # Prompt for MINERNAME
    echo "Please enter miner name: "
    read MINERNAME
    # Start the miner
    start_miner "$network" "$WALLETNAME" "$HOTKEY" "$MINERNAME"
fi


ver.1.1
#!/bin/bash

# Function to display a countdown
countdown() {
    local count=$1
    while [ $count -gt 0 ]; do
        echo -ne "$count\033[0K\r"
        sleep 1
        ((count--))
    done
}

# Function to install SubVortex
install_subvortex() {
    echo "Installing SubVortex"
    countdown 3
    sudo apt update && sudo apt upgrade -y
    sudo apt install git nodejs npm -y
    sudo npm i -g pm2
	apt install expect -y
    sudo apt install python3-pip expect -y
    cd $HOME
    git clone https://github.com/eclipsevortex/SubVortex.git
    cd SubVortex
    sleep 2
    echo "Installing Dependencies"
    countdown 3
    pip install -r requirements.txt
    pip install -e .
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
        return 1
    fi

    echo "Installing Local Subtensor on $network_arg"
    countdown 3
    cd $HOME/SubVortex/scripts/subtensor/
    ./setup.sh $network_arg binary $HOME
    echo "Starting Local Subtensor with pm2..."
    countdown 3
    pm2 start start.sh --name subtensor_$network_arg -- $network_arg binary $HOME
    pm2 save
    echo "Subtensor is now running in the background managed by pm2."
}

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt=$1
    local yn
    read -p "$prompt (yes, y or no, n): " yn
    case $yn in
        [Yy]* ) return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes or no."; prompt_yes_no "$prompt";;
    esac
}

# Function to start the miner
start_miner() {
    local network=$1
    local WALLETNAME=$2
    local HOTKEY=$3
    local MINERNAME=$4
    echo "Starting Miner...Remember to Register your hotkey on network $network"
    countdown 5
    cd $HOME/SubVortex/
    pm2 start neurons/miner.py --name "$MINERNAME" --interpreter python3 -- --netuid "$network" --subtensor.network local --wallet.name "$WALLETNAME" --wallet.hotkey "$HOTKEY" --logging.debug
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
    echo "Creating a new ColdWallet..." >> "$WALLETBACKUP"
    btcli w new_coldkey >> "$WALLETBACKUP"
fi

# Prompt for HotKey creation
if prompt_yes_no "Do you want to create a new HotKey?"; then
    echo "Creating a new HotKey..." >> "$WALLETBACKUP"
    btcli w new_hotkey >> "$WALLETBACKUP"
fi

# Prompt for starting miner
if prompt_yes_no "Do you want to start miner?"; then
    # Prompt for WALLETNAME
    echo "Please enter WALLETNAME: "
    read WALLETNAME
    # Prompt for HOTKEYNAME
    echo "Please enter HOTKEYNAME: "
    read HOTKEY
    # Prompt for MINERNAME
    echo "Please enter miner name: "
    read MINERNAME
    # Start the miner
    start_miner "$network" "$WALLETNAME" "$HOTKEY" "$MINERNAME"
fi
