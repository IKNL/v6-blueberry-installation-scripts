#!/bin/bash

# Print the current time and user
echo "Current time: $(date)" &>> docker-install.log
echo "Current user: $(whoami)" &>> docker-install.log

# Update the apt package index
sudo yum update -y &>> docker-install.log

# Install necessary packages
sudo yum install -y yum-utils &>> docker-install.log

# Set up the stable repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/oracle/docker-ce.repo &>> docker-install.log

# Install the latest version of Docker Engine and containerd
sudo yum install -y docker-ce docker-ce-cli containerd.io &>> docker-install.log

# Start Docker
sudo systemctl start docker &>> docker-install.log

# Enable Docker to start on boot
sudo systemctl enable docker &>> docker-install.log

# Add the current user to the docker group
sudo usermod -aG docker $USER &>> docker-install.log

# Apply the new group membership to the current session
newgrp docker &>> docker-install.log