#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")
source $SCRIPT_DIR/utils.sh

# Add a cron job that runs the start.sh script at startup
print_step "Adding cron job"
if ! check_command "crontab"; then
    if confirm "Crontab is not installed. Do you want to install it?"; then
        sudo dnf install crontabs -y
    else
        print_error "Crontab is required to add a cron job."
        print_error "No cron job added"
    fi
else
    if ! (crontab -l 2>/dev/null | grep -q "$SCRIPT_DIR/start.sh"); then
        (crontab -l 2>/dev/null; echo "@reboot $SCRIPT_DIR/start.sh") | crontab -
        print_step "Succesfully added cron job."
    else
        print_warning "Cron job already exists."
    fi
fi