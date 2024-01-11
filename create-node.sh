#! /bin/bash
source $SCRIPT_DIR/utils.sh
CONFIG_FILE=$HOME/.config/vantage6/node/blueberry.yaml
CONFIG_FILE_TEMPLATE=$SCRIPT_DIR/node.tpl

WRITE_CONFIG_FILE=true
if [ -f "$CONFIG_FILE" ]; then
    print_warning "Config file already exists at $CONFIG_FILE"
    if confirm "Do you want to overwrite the config file?"; then
        print_step "Overwriting the config file"
    else
        print_step "Using the existing config file"
        WRITE_CONFIG_FILE=false
    fi
fi


if [ "$WRITE_CONFIG_FILE" = true ]; then

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

    # OMOP database settings
    export OMOP_PORT=5432
    export OMOP_DATABASE="postgres"
    export OMOP_USER="postgres"
    export OMOP_PASSWORD="postgres"
    export OMOP_CDM_SCHEMA="cmd"
    export OMOP_RESULT_SCHEMA="result"

    # depending on the method selected we need to inject a different block in the
    # config file
    select_database_method

    case "$DB_METHOD" in
        "Docker-service")
            # Code to execute if DB_METHOD is "docker"
            user_input "Please enter the OMOP container name"
            export OMOP_HOST=$REPLY
            export DOCKER_SERVICE_CONTAINER_LABEL=$REPLY
            include_content=$(<$SCRIPT_DIR/templates/docker-service.tpl)

            ;;
        "SSH-tunnel")
            # Code to execute if DB_METHOD is "ssh_tunnel"
            export OMOP_HOST="omop"
            include_content=$(<$SCRIPT_DIR/templates/ssh-tunnel.tpl)
            source $SCRIPT_DIR/create-ssh-tunnel.sh
            ;;
        *)
            # Code to execute if DB_METHOD is anything else
            print_error "Invalid option $DB_METHOD. Exiting..."
            exit 1
            ;;
    esac

    escaped_content=$(echo "$include_content" | sed -e ':a' -e 'N' -e '$!ba' -e 's/[\/&]/\\&/g' -e 's/\n/NEWLINE/g')
    sed "s/{{DATABASE_CONNECTION}}/$escaped_content/g" $SCRIPT_DIR/templates/node-config.tpl | sed 's/NEWLINE/\n/g' > $CONFIG_FILE_TEMPLATE
    # sed "s/{{DATABASE_CONNECTION}}/$escaped_content/" $SCRIPT_DIR/templates/node-config.tpl > $CONFIG_FILE_TEMPLATE

    # # Create the config file
    print_step "Creating the config file"
    mkdir -p $HOME/.config/vantage6/node

    print_step "Creating the vantage6 config file"
    create_config_file $CONFIG_FILE_TEMPLATE $CONFIG_FILE
fi


