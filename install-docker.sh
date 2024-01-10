#!/bin/bash

# Print the current time and user
source $SCRIPT_DIR/utils.sh
print_info &>> $LOG_DIR/docker-install.log

print_step "Checking if Docker is already installed"
if command -v docker &> /dev/null
then
    print_warning "Docker is already installed" | tee -a $LOG_DIR/docker-install.log
else

    # Update the apt package index
    print_step "Updating the current system"
    sudo dnf update -y &>> $LOG_DIR/docker-install.log

    # Install necessary packages
    print_step "Installing necessary packages"
    sudo dnf install -y dnf-utils &>> $LOG_DIR/docker-install.log

    # Set up the stable repository
    print_step "Setting up the stable repository"
    sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo &>> $LOG_DIR/docker-install.log

    # Install the latest version of Docker Engine and containerd
    print_step "Installing Docker"
    sudo dnf install docker-ce --nobest -y --allowerasing &>> $LOG_DIR/docker-install.log

    # Start Docker
    print_step "Starting Docker"

    # Enable Docker to start on boot
    print_step "Enabling Docker to start on boot & start Docker"
    if command -v systemctl &> /dev/null
    then
        sudo systemctl enable docker &>> $LOG_DIR/docker-install.log
        sudo systemctl start docker
    else
        print_warning "Systemctl not found, are you testing?"
        print_warning "If not, docker will not start automatically on boot"
        sudo service docker start
    fi
fi

if getent group docker >/dev/null; then
    print_warning "The docker group already exists"
else
    print_step "Adding the docker group"
    sudo groupadd docker &>> $LOG_DIR/docker-install.log
fi

# Add the current user to the docker group
if groups $USER | grep &>/dev/null '\bdocker\b'; then
    print_step "The user '$USER' is already in the docker group"
else
    print_step "Adding the current user '$USER' to the docker group"
    sudo usermod -aG docker $USER &>> $LOG_DIR/docker-install.log
fi