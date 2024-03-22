# SubVortex Full Setup Script

This repository contains a script designed to automate the installation and setup process for the SubVortex subnet on Bittensor. The script simplifies the process of installing SubVortex, its dependencies, and configuring the Subtensor network (either mainnet or testnet). Additionally, it assists with the creation of a new ColdWallet and HotKey, and provides an easy way to start the miner.

## Purpose of the Script

The `SubVortex_FullSetup.sh` script is intended to:

- Install SubVortex and its required dependencies.
- Install and start the local Subtensor node on the chosen network (mainnet or testnet).
- Prompt the user to create a new ColdWallet and HotKey.
- Prompt the user to start the miner.

## Prerequisites

Before running the script, ensure that you have:

- A Linux-based operating system with `sudo` privileges.
- Internet connectivity for downloading necessary packages and cloning the SubVortex repository.

## How to Download and Run the Script

Follow these steps to download, make the script executable, and run it:

1. Open your terminal.

2. Download the script using `wget`:

   ```bash
   wget https://raw.githubusercontent.com/TidalWavesNode/SubVortex_Setup/main/SubVortex_FullSetup.sh
   ```

3. Make the script executable:

   ```bash
   chmod +x SubVortex_FullSetup.sh
   ```

4. Run the script:

   ```bash
   ./SubVortex_FullSetup.sh
   ```

## Running the Script

When you run the script, it will guide you through the following steps:

1. Installation of SubVortex and its dependencies.
2. Choice of network type for Subtensor (mainnet or testnet).
3. Option to create a new ColdWallet.
4. Option to create a new HotKey.
5. Option to start the miner, with prompts for UID, WALLETNAME, HOTKEYNAME, and MINERNAME.

Follow the on-screen prompts to complete the setup process.

## Support

If you encounter any issues or have questions regarding the setup process, please reach out to the SubVortex team in their Bittensor Discord channel [SubVortex] (https://discord.com/channels/799672011265015819/1215311984799653918)

## Contributions

Contributions to the script are welcome. If you have improvements or fixes, please fork the repository, make your changes, and submit a pull request.

## License

This script is provided under an open-source license. Please check the repository for the specific license details.

## Disclaimer

This script is provided "as is", without warranty of any kind. Use at your own risk. Always review scripts and code before running them on your system.
