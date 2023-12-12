#!/bin/bash

# Print the current time and user
source ./utils.sh
print_info &>> miniconda-install.log

# Check if Miniconda is already installed
print_step "Checking if Miniconda is already installed"
if command -v conda &> /dev/null; then
    print_step "Miniconda is already installed." | tee -a miniconda-install.log
else
    # Download the Miniconda installer script
    print_step "Downloading the Miniconda installer script"
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh &>> miniconda-install.log

    # Run the installer script
    print_step "Running the Miniconda installer script"
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda &>> miniconda-install.log

    # Initialize Miniconda to automatically update the PATH
    print_step "Initializing Miniconda to automatically update the PATH"
    $HOME/miniconda/bin/conda init &>> miniconda-install.log

    # Activate the base environment
    print_step "Activating the base environment"
    source ~/.bashrc
fi