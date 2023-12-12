#!/bin/bash

source ./utils.sh
print_intro
confirm_or_exit

# Update the current system
print_header "Updating the current system"
sudo dnf update -y &>> update-system.log

# Run the install-docker.sh script
print_header "Installing Docker"
source ./install-docker.sh

# Run the install-miniconda.sh script
print_header "Installing Miniconda"
source ./install-miniconda.sh

# Run the install-vantage6.sh script
print_header "Installing vantage6"
source ./install-vantage6.sh

# Configure the vantage6-node
print_header "Creating vantage6-node"
source ./create-node.sh

print_outro
