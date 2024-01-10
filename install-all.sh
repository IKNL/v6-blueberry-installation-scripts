#!/bin/bash

SCRIPT_DIR=$(realpath "$(dirname "$0")")

source $SCRIPT_DIR/utils.sh
LOG_DIR=$SCRIPT_DIR/logs

print_intro
confirm_or_exit
mkdir -p $LOG_DIR

# Update the current system
print_header "Updating the current system (this may take a while)"
sudo dnf update -y &>> $LOG_DIR/update-system.log
print_step "System updated"

# Run the install-docker.sh script
print_header "Installing Docker"
source $SCRIPT_DIR/install-docker.sh

# Run the install-miniconda.sh script
print_header "Installing Miniconda"
source $SCRIPT_DIR/install-miniconda.sh

# Run the install-vantage6.sh script
print_header "Installing vantage6"
source $SCRIPT_DIR/install-vantage6.sh

# Configure the vantage6-node
print_header "Creating vantage6-node"
source $SCRIPT_DIR/create-node.sh

print_header "Post installation steps"
if confirm "Do you want to create a cronjob to automatically start the vantage6-node on boot?"; then
    source $SCRIPT_DIR/create-cronjob.sh
fi

if confirm "Do you want to start the vantage6-node now?"; then
    source $SCRIPT_DIR/node.sh start blueberry
fi




print_outro
