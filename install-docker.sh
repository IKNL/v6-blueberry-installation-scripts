#!/bin/bash

# Print the current time and user
source ./utils.sh
print_info &>> docker-install.log

print_step "Checking if Docker is already installed"
if command -v docker &> /dev/null
then
    print_step "Docker is already installed" | tee -a docker-install.log
else

    # Update the apt package index
    print_step "Updating the current system"
    sudo dnf update -y &>> docker-install.log

    # Install necessary packages
    print_step "Installing necessary packages"
    sudo dnf install -y dnf-utils &>> docker-install.log

    # Set up the stable repository
    print_step "Setting up the stable repository"
    sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo &>> docker-install.log

    # Install the latest version of Docker Engine and containerd
    print_step "Installing Docker"
    sudo dnf install docker-ce --nobest -y &>> docker-install.log

    # Start Docker
    print_step "Starting Docker"

    # Enable Docker to start on boot
    print_step "Enabling Docker to start on boot & start Docker"
    if command -v systemctl &> /dev/null
    then
        sudo systemctl enable docker &>> docker-install.log
        sudo systemctl start docker
    else
        print_warning "Systemctl not found, are you testing?"
        print_warning "If not, docker will not start automatically on boot"
        sudo service docker start
    fi

    # Add the current user to the docker group
    print_step "Adding the current user '$USER' to the docker group"
    sudo usermod -aG docker $USER &>> docker-install.log

    # Apply the new group membership to the current session
    print_step "Applying the new group membership to the current session"
    newgrp docker &>> docker-install.log
fi