#! /bin/bash

source ./utils.sh

# Create config dir
print_step "Creating config dir"
mkdir -p ~/.config

# Create config file
print_step "Creating config file"
echo "  - Please enter the API key:"
read API_KEY

# vantage6 node settings
export API_KEY=$API_KEY
export TASK_DIR=$HOME/tasks

mkdir -p $TASK_DIR

# OMOP settings
export OMOP_HOST="omop"
export OMOP_PORT=5432

# TODO @biomeris which settings?
export OMOP_DATABASE="postgres"
export OMOP_USER="postgres"
export OMOP_PASSWORD="postgres"
export OMOP_CDM_SCHEMA="cmd"
export OMOP_RESULT_SCHEMA="result"

# Check if the vantage6-node user already exists
print_step "Checking if the vantage6-node user already exists"
NEW_USER="vantage6-node"
if id -u "vantage6-node" >/dev/null 2>&1; then
    print_step "The vantage6-node user already exists"
else
    print_step "Creating new user"
    sudo useradd $NEW_USER

    # Set password for the new user
    PASSWORD=$(openssl rand -base64 16)
    echo $PASSWORD | sudo passwd --stdin $NEW_USER
fi


print_step "Executing some steps as the $NEW_USER user"
# Run the create_ssh_key.sh script as the new user
# sudo -u $NEW_USER bash -c "./create_ssh_user.sh" | tee /dev/stdout
print_step "Changing back to the original user"

# Tunnel settings
print_step "Setting tunnel settings"
# export TUNNEL_HOSTNAME=$OMOP_HOST
# export SSH_HOST=$(hostname -I | awk '{print $1}')
# print_step "SSH_HOST: $SSH_HOST"
# export SHH_PORT=22
# export SSH_HOST_FINGERPRINT=$(cat /etc/ssh/ssh_host_rsa_key.pub)

# export SSH_USERNAME=$NEW_USER
# export SSH_KEY=$PRIVATE_KEY_FILE

# export TUNNEL_BIND_IP="0.0.0.0"
# export TUNNEL_BIND_PORT=$OMOP_PORT

# export TUNNEL_REMOTE_IP="127.0.0.1"
# export TUNNEL_REMOTE_PORT=5432

# # Create the config file
print_step "Creating the config file"
# print_step $USER
# mkdir -p ~/.config/vantage6/node
# envsubst < ./v6-blueberry-installation-scripts/node.tpl > $HOME/.config/vantage6/node/blueberry.yml
# cat << EOF > ~/.config/vantage6/node/config.yml


