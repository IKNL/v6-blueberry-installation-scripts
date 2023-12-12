#!/bin/bash

function print_info() {
    echo "Current time: $(date)"
    echo "Current executing user: $(whoami)"
    echo "Original executing user: $USER"
}

function print_divider() {
    echo "============================================================================="
}

function print_step() {
    echo "  - $1"
}

function print_warning() {
    echo "  WARNING: $1"
}

function print_header(){
    print_divider
    echo "$1"
    print_divider
}

function print_intro(){
    print_header "vantage6 installation script"
    echo "This script will install the following:"
    echo ""
    echo "  - Docker"
    echo "  - Miniconda"
    echo "  - vantage6-node"
    echo ""
    echo "The user 'vantage6-node' is created. This user has no sudo privileges."
    echo "This user is used to setup a SSH tunnel from the vantage6 node to this "
    echo "(host) machine which hosts the OMOP database. For this to work, the "
    echo "user needs to be able to SSH into the host machine without a password."
    echo "Therefore a private/public key pair is generated for this user and "
    echo "the public key is added to the authorized_keys file of this machine."
    echo "The private key of this user is then mounted by the vantage6-node!"
    echo ""
    echo "The conda environment 'vantage6' is created. This environment contains "
    echo "the vantage6 CLI."
    echo ""
    echo "The OMOP database is to be expected to be running on this machine when "
    echo "the node is started. Make sure it listens on port 5432."
    echo ""
}

print_outro(){
    print_header "Installation complete"
    echo "To check if any installation steps failed, check the log files:"
    echo ""
    echo "  - update-system.log"
    echo "  - docker-install.log"
    echo "  - miniconda-install.log"
    echo "  - vantage6-install.log"
    echo "  - create-node.log"
    echo ""
    echo "If you want to use the vantage6 CLI you need to activate the vantage6 "
    echo "conda environment:"
    echo ""
    echo "  conda activate vantage6"
    echo ""
    echo "Make sure the OMOP database is running and listening on 127.0.0.1:5432 "
    echo "before starting the vantage6-node."
    print_divider
}

confirm() {
    read -p "$1 (y/n) " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

confirm_or_exit() {
    if ! confirm "Are you sure you want to continue?"; then
        exit 1
    fi
}

