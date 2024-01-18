#! /bin/bash
source $SCRIPT_DIR/utils.sh
CONFIG_FILE=$HOME/.config/vantage6/node/blueberry.yaml
CONFIG_FILE_TEMPLATE=$SCRIPT_DIR/node.tpl

WRITE_CONFIG_FILE=true
KEEP_PREVIOUS_SETTINGS=false
if [ -f "$CONFIG_FILE" ]; then
    print_warning "Config file already exists at $CONFIG_FILE"

    select_config_option

    if [ "$CONFIG_OPTION" = "1" ]; then
        print_step "Overwriting config file"
    elif [ "$CONFIG_OPTION" = "2" ]; then
        print_step "Updating config file"
        WRITE_CONFIG_FILE=true
        KEEP_PREVIOUS_SETTINGS=true
    elif [ "$CONFIG_OPTION" = "3" ]; then
        print_step "Skipping config file creation"
        WRITE_CONFIG_FILE=false
    fi

fi


if [ "$WRITE_CONFIG_FILE" = true ]; then


    if [ "$KEEP_PREVIOUS_SETTINGS" = true ]; then
        # check that $SCRIPT_DIR/settings.env exists
        if [ ! -f "$SCRIPT_DIR/settings.env" ]; then
            print_error "settings.env file not found at $SCRIPT_DIR/settings.env"
            print_error "You need to enter the settings manually"
            KEEP_PREVIOUS_SETTINGS=false
        else
            print_step "Using previous settings"
            # we want to safe the newly inputted data
            source $SCRIPT_DIR/settings.env
        fi
    fi

    # Create config dir
    print_step "Creating config dir"
    mkdir -p $HOME/.config

    # Create config file
    print_step "Creating config file"

    # Vantage6 node settings
    export TASK_DIR=$HOME/tasks
    mkdir -p $TASK_DIR

    is_set_or_prompt "API_KEY"
    export API_KEY=$API_KEY

    # OMOP database settings
    is_set_or_prompt "OMOP_PORT"
    export OMOP_PORT=$OMOP_PORT
    is_set_or_prompt "OMOP_DATABASE"
    export OMOP_DATABASE=$OMOP_DATABASE
    is_set_or_prompt "OMOP_USER"
    export OMOP_USER=$OMOP_USER
    is_set_or_prompt "OMOP_PASSWORD"
    export OMOP_PASSWORD=$OMOP_PASSWORD
    is_set_or_prompt "OMOP_CDM_SCHEMA"
    export OMOP_CDM_SCHEMA=$OMOP_CDM_SCHEMA
    is_set_or_prompt "OMOP_RESULT_SCHEMA"
    export OMOP_RESULT_SCHEMA=$OMOP_RESULT_SCHEMA


    if is_set "OMOP_HOST" "silent"; then
        if is_set "DOCKER_SERVICE_CONTAINER_LABEL" "silent"; then
            print_step "Using previous Docker service container label: $DOCKER_SERVICE_CONTAINER_LABEL"
            DB_METHOD="Docker-service"
        else
            print_step "Using previous SSH OMOP_HOST: $OMOP_HOST"
            DB_METHOD="SSH-tunnel"
        fi
    else
        # depending on the method selected we need to inject a different block in the
        # config file
        select_database_method
    fi

    case "$DB_METHOD" in
        "Docker-service")
            # Code to execute if DB_METHOD is "docker"
            if ! is_set "OMOP_HOST" "silent"; then
                user_input "Please enter the OMOP container name"
                OMOP_HOST=$REPLY
            fi

            export OMOP_HOST=$OMOP_HOST
            export DOCKER_SERVICE_CONTAINER_LABEL=$OMOP_HOST
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

    if [ "$KEEP_PREVIOUS_SETTINGS" = false ]; then
        print_step "Creating environment file"
        echo "export API_KEY=$API_KEY" > $SCRIPT_DIR/settings.env
        echo "export OMOP_PORT=$OMOP_PORT" >> $SCRIPT_DIR/settings.env
        echo "export OMOP_DATABASE=$OMOP_DATABASE" >> $SCRIPT_DIR/settings.env
        echo "export OMOP_USER=$OMOP_USER" >> $SCRIPT_DIR/settings.env
        echo "export OMOP_PASSWORD=$OMOP_PASSWORD" >> $SCRIPT_DIR/settings.env
        echo "export OMOP_CDM_SCHEMA=$OMOP_CDM_SCHEMA" >> $SCRIPT_DIR/settings.env
        echo "export OMOP_RESULT_SCHEMA=$OMOP_RESULT_SCHEMA" >> $SCRIPT_DIR/settings.env
        echo "export OMOP_HOST=$OMOP_HOST" >> $SCRIPT_DIR/settings.env
        if is_set "DOCKER_SERVICE_CONTAINER_LABEL" "silent"; then
            echo "export DOCKER_SERVICE_CONTAINER_LABEL=$DOCKER_SERVICE_CONTAINER_LABEL" >> $SCRIPT_DIR/settings.env
        fi
    fi
fi


