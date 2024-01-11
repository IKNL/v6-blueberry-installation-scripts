#!/bin/bash

source $SCRIPT_DIR/utils.sh

# Generate a new SSH key pair

PRIVATE_KEY_FILE=$HOME/tunnel_id_rsa

# we need to do this ugly as we do not have permissions to check if the file exists
if [ ! -f "$PRIVATE_KEY_FILE" ]; then
    print_step "$PRIVATE_KEY_FILE does not exist"
    print_step "Generating a new SSH key pair"
    sudo ssh-keygen -t rsa -b 4096 -f $PRIVATE_KEY_FILE -N "" -C "vantage6-tunnel"
else
    print_warning "SSH key already exists at $PRIVATE_KEY_FILE"
fi

# Add the public key to the authorized_keys file
print_step "Adding the public key to the authorized_keys file of the SSH user"
NEW_USER_HOME=/home/$NEW_USER
sudo mkdir -p $NEW_USER_HOME/.ssh
PUBLIC_KEY=$(sudo cat $PRIVATE_KEY_FILE.pub)
sudo touch $NEW_USER_HOME/.ssh/authorized_keys
if ! sudo grep -q "$PUBLIC_KEY" $NEW_USER_HOME/.ssh/authorized_keys; then
    echo $PUBLIC_KEY | sudo tee -a $NEW_USER_HOME/.ssh/authorized_keys > /dev/null
else
    print_warning "Public key already exists in the authorized_keys file"
fi

# Set the correct permissions
print_step "Setting the correct file permissions"
sudo chmod 700 $NEW_USER_HOME/.ssh
sudo chmod 600 $NEW_USER_HOME/.ssh/authorized_keys
sudo chmod 777 $HOME/tunnel_id_rsa
sudo chmod 644 $HOME/tunnel_id_rsa.pub

# Change the owner to $NEW_USER
print_step "Changing the owner of the files to $NEW_USER"
sudo chown -R $NEW_USER:$NEW_USER $NEW_USER_HOME/.ssh

print_step "SSH configuration complete"