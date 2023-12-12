#!/bin/bash

# Switch to the new user's home directory
cd ~

# Generate a new SSH key pair
echo "Generating a new SSH key pair"
mkdir -p ~/.ssh
PRIVATE_KEY_FILE="~/.ssh/id_rsa"
ssh-keygen -t rsa -b 4096 -f $PRIVATE_KEY_FILE -N ""

# Add the public key to the authorized_keys file
echo "Adding the public key to the authorized_keys file"
PUBLIC_KEY=$(cat $PRIVATE_KEY_FILE.pub)
touch ~/.ssh/authorized_keys
echo $PUBLIC_KEY >> ~/.ssh/authorized_keys

# Set the correct permissions
echo "Setting the correct permissions"
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub