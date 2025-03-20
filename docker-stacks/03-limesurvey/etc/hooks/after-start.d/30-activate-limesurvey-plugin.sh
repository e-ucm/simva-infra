#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/.initialized" ]]; then 
    # Variable
    export RUN_IN_CONTAINER=true
    export RUN_IN_AS_SPECIFIC_USER="root"
    export RUN_IN_CONTAINER_NAME="limesurvey"
    PLUGIN_DEST="/var/www/html/plugins/"      # Destination inside the container

    # Step 1: Clear LimeSurvey cache
    echo "Clearing LimeSurvey cache..."
    "${SIMVA_HOME}/bin/run-command.sh" rm -rf /var/www/html/tmp/runtime/cache/*

    # Step 2: Set ownership and permissions (adjust user if needed)
    echo "Setting ownership and permissions..."
    "${SIMVA_HOME}/bin/run-command.sh" chown -R www-data:www-data "$PLUGIN_DEST"
    "${SIMVA_HOME}/bin/run-command.sh" chmod -R 755 "$PLUGIN_DEST"
    
    # Step 3: Insert the Plugins
    export RUN_IN_CONTAINER_NAME="mariadb"  # The name of your MySQL container
    DB_NAME=$SIMVA_LIMESURVEY_MYSQL_DATABASE
    DB_USER=$SIMVA_LIMESURVEY_MYSQL_USER
    DB_PASSWORD=$SIMVA_LIMESURVEY_MYSQL_PASSWORD
    
    WEBHOOK_PLUGIN_NAME="LimeSuveyStatusWebhookPlugin"
    WEBHOOK_PLUGIN_VERSION="1.0.0"
    OAUTH2_PLUGIN_NAME="AuthOAuth2"
    OAUTH2_PLUGIN_VERSION="1.5.0"

    echo "Inserting plugin $WEBHOOK_PLUGIN_NAME into the plugins table..."
    "${SIMVA_HOME}/bin/run-command.sh" mysql -u $DB_USER -p"$DB_PASSWORD" -e "
    USE $DB_NAME;
    INSERT INTO \`plugins\` (name, plugin_type, active, priority, version)
    VALUES ('$WEBHOOK_PLUGIN_NAME', 'user', 1, 0, '$WEBHOOK_PLUGIN_VERSION');
    "
    
    echo "Inserting plugin $OAUTH2_PLUGIN_NAME into the plugins table..."
    "${SIMVA_HOME}/bin/run-command.sh" mysql -u $DB_USER -p"$DB_PASSWORD" -e "
    USE $DB_NAME;
    INSERT INTO \`plugins\` (name, plugin_type, active, priority, version)
    VALUES ('$OAUTH2_PLUGIN_NAME', 'user', 1, 0, '$OAUTH2_PLUGIN_VERSION');
    "

    echo "Plugin $PLUGIN_NAME has been installed and its settings have been added!"
fi