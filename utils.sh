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
    echo -e "\e[33m  - $1\e[0m"
}

function print_error() {
    echo -e "\e[31m  - $1\e[0m"
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
    echo "  - $LOG_DIR/update-system.log"
    echo "  - $LOG_DIR/docker-install.log"
    echo "  - $LOG_DIR/miniconda-install.log"
    echo "  - $LOG_DIR/vantage6-install.log"
    echo "  - $LOG_DIR/create-node.log"
    echo ""
    echo "If you want to use the vantage6 CLI you need to activate the vantage6 "
    echo "conda environment:"
    echo ""
    echo "  conda activate vantage6"
    echo ""
    echo "Make sure the OMOP database is running and listening on $TUNNEL_REMOTE_IP:$TUNNEL_REMOTE_PORT "
    echo "before starting the vantage6-node."
    echo ""
    echo -e "\e[1;32mYou need to restart this machine before you can start the node.\e[0m"

    print_divider
}

confirm() {
    echo -e -n "\e[32m  ? $1 (y/n) \e[0m"
    read -n1 response
    echo
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

create_config_file() {
    envsubst < "$1" > "$2"
    print_step "Config file created at $2"
}


check_command() {
    local command_name="$1"

    # Check if the command is installed
    if ! command -v "$command_name" &> /dev/null; then
        print_error "$command_name is not installed" >&2
        return 1
    fi

    return 0
}

check_env() {
    local env_name="$1"

    # Check if the environment exists
    if ! conda env list | grep -q "^$env_name "; then
        print_error "conda environment '$env_name' does not exist" >&2
        return 1
    fi

    return 0
}

is_set() {
    local var_name="$1"
    local silent="$2"
    if [ -z "${!var_name}" ]; then
        if [ "$silent" != "silent" ]; then
            print_warning "Variable '$var_name' is not set" >&2
        fi
        return 1
    fi

    return 0
}
set_if_unset() {
    local var_name="$1"
    local value="$2"

    if [ -z  "${!var_name}" ]; then
        eval "$var_name=$value"
    fi
}
is_set_or_prompt() {
    local var_name="$1"

    if ! is_set "$var_name"; then
        echo -n "  ? Please enter the value for $var_name: "; read -r VALUE
        eval "$var_name=$VALUE"
    fi
}

select_database_method() {
    print_step "The following database options are available:"
    # print_step "Please choose an option:"
    local options=("SSH-tunnel" "Docker-service")
    for i in "${!options[@]}"; do
        echo "  # $((i+1)). ${options[$i]}"
    done

    while true; do
        echo -e -n "\e[32m  ? Please select an option: \e[0m"; read -n1 -r REPLY
        if [[ $REPLY -ge 1 && $REPLY -le ${#options[@]} ]]; then
            opt="${options[$((REPLY-1))]}"
            break
        else
            print_error "Invalid option. Please try again."
        fi
    done
    DB_METHOD=$opt
    print_step $DB_METHOD
}

select_config_option() {
    local options=(
        "Delete existing config file and create a new one"
        "Update existing config file with previous settings (e.g. API key, OMOP)"
        "Keep existing config file and do not update it"
    )
    for i in "${!options[@]}"; do
        echo "  # $((i+1)). ${options[$i]}"
    done

    while true; do
        echo -e -n "\e[32m  ? Please select an option: \e[0m"; read -n1 -r REPLY
        if [[ $REPLY -ge 1 && $REPLY -le ${#options[@]} ]]; then
            opt="${options[$((REPLY-1))]}"
            break
        else
            print_error "Invalid option. Please try again."
        fi
    done
    CONFIG_OPTION=$REPLY
    print_step $opt

}



user_input() {
    echo -e -n "\e[32m  ? $1: \e[0m"; read -r REPLY
}

