#!/bin/bash

source $SCRIPT_DIR/utils.sh

# Generate a new SSH key pair
NEW_USER_HOME=/home/$NEW_USER
sudo mkdir -p $NEW_USER_HOME/.ssh
PRIVATE_KEY_FILE=$NEW_USER_HOME/.ssh/id_rsa
# we need to do this ugly as we do not have permissions to check if the file exists
if sudo sh -c "[ ! -f \"$PRIVATE_KEY_FILE\" ]"; then
    print_step "$PRIVATE_KEY_FILE does not exist"
    print_step "Generating a new SSH key pair"
    sudo ssh-keygen -t rsa -b 4096 -f $PRIVATE_KEY_FILE -N "" -C "$NEW_USER"
else
    print_warning "SSH key already exists at $PRIVATE_KEY_FILE"
fi

# Add the public key to the authorized_keys file
print_step "Adding the public key to the authorized_keys file"
PUBLIC_KEY=$(sudo cat $PRIVATE_KEY_FILE.pub)
sudo touch $NEW_USER_HOME/.ssh/authorized_keys
if ! sudo grep -q "$PUBLIC_KEY" $NEW_USER_HOME/.ssh/authorized_keys; then
    sudo echo $PUBLIC_KEY >> $NEW_USER_HOME/.ssh/authorized_keys
else
    print_warning "Public key already exists in the authorized_keys file"
fi

# Set the correct permissions
print_step "Setting the correct file permissions"
sudo chmod 700 $NEW_USER_HOME/.ssh
sudo chmod 600 $NEW_USER_HOME/.ssh/authorized_keys
sudo chmod 600 $NEW_USER_HOME/.ssh/id_rsa
sudo chmod 644 $NEW_USER_HOME/.ssh/id_rsa.pub

# Change the owner to $NEW_USER
print_step "Changing the owner of the files to $NEW_USER"
sudo chown -R $NEW_USER:$NEW_USER $NEW_USER_HOME/.ssh

print_step "SSH configuration complete"