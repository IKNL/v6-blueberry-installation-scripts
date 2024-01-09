#! /bin/bash

source $SCRIPT_DIR/utils.sh

# Create config dir
print_step "Creating config dir"
mkdir -p $HOME/.config

# Create config file
print_step "Creating config file"
echo -n "  ? Please enter the API key: "; read -r API_KEY

# vantage6 node settings
export API_KEY=$API_KEY
export TASK_DIR=$HOME/tasks

mkdir -p $TASK_DIR

# OMOP settings
export OMOP_HOST="omop"
export OMOP_PORT=5432

export OMOP_DATABASE="postgres"
export OMOP_USER="postgres"
export OMOP_PASSWORD="postgres"
export OMOP_CDM_SCHEMA="cmd"
export OMOP_RESULT_SCHEMA="result"

# Check if the vantage6-node user already exists
print_step "Checking if the vantage6-node user already exists"
NEW_USER="vantage6-node"
if id -u "vantage6-node" >/dev/null 2>&1; then
    print_warning "The vantage6-node user already exists"
else
    print_step "Creating new user: $NEW_USER"
    sudo useradd $NEW_USER

    # Set password for the new user
    PASSWORD=$(openssl rand -base64 16)
    echo "$NEW_USER:$PASSWORD" | sudo chpasswd
fi


print_step "Executing some steps as sudo user"
source $SCRIPT_DIR/create-ssh-user.sh

# Tunnel settings
print_step "Setting tunnel settings"
export TUNNEL_HOSTNAME=$OMOP_HOST
export SSH_HOST=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
export SSH_PORT=22
print_step "SSH_HOST: $SSH_HOST, SSH_PORT: $SSH_PORT"


if [ -f "/etc/ssh/ssh_host_rsa_key.pub" ]; then
    export SSH_HOST_FINGERPRINT=$(cat /etc/ssh/ssh_host_rsa_key.pub)
else
    print_error "File /etc/ssh/ssh_host_rsa_key.pub does not exist."
    print_error "Is openssh-server installed and running?"
fi

export SSH_USERNAME=$NEW_USER
export SSH_KEY=$PRIVATE_KEY_FILE
print_step "SSH_KEY: $SSH_KEY"

export TUNNEL_BIND_IP="0.0.0.0"
export TUNNEL_BIND_PORT=$OMOP_PORT

export TUNNEL_REMOTE_IP="127.0.0.1"
export TUNNEL_REMOTE_PORT=5432
print_step "TUNNEL_REMOTE_PORT: $TUNNEL_REMOTE_PORT"

# # Create the config file
print_step "Creating the config file"
mkdir -p $HOME/.config/vantage6/node
CONFIG_FILE=$HOME/.config/vantage6/node/blueberry.yml

if [ -f "$HOME/.config/vantage6/node/blueberry.yml" ]; then
    print_warning "Config file already exists at $CONFIG_FILE"
    if confirm "Do you want to overwrite the config file?"
    then
        print_step "Overwriting the config file"
        create_config_file $SCRIPT_DIR $CONFIG_FILE
    fi
else
    print_step "Creating the vantage6 config file"
    create_config_file $SCRIPT_DIR $CONFIG_FILE
fi

