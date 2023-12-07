#!/bin/bash

# Print the current time and user
echo "Current time: $(date)" &>> miniconda-install.log
echo "Current user: $(whoami)" &>> miniconda-install.log

# Download the Miniconda installer script
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh &>> miniconda-install.log

# Run the installer script
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda &>> miniconda-install.log

# Initialize Miniconda to automatically update the PATH
$HOME/miniconda/bin/conda init &>> miniconda-install.log