#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Variable
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"
export RUN_IN_CONTAINER_NAME="limesurvey"

# Step 1: Clear LimeSurvey cache
echo "Clearing LimeSurvey cache..."
"${SIMVA_HOME}/bin/run-command.sh" rm -rf /var/www/html/tmp/runtime/cache/*

if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/.initialized" ]]; then     
    # Step 2: Insert the Plugins
    export RUN_IN_CONTAINER_NAME="mariadb"  # The name of your MySQL container
    DB_NAME=$SIMVA_LIMESURVEY_MYSQL_DATABASE
    DB_USER=$SIMVA_LIMESURVEY_MYSQL_USER
    DB_PASSWORD=$SIMVA_LIMESURVEY_MYSQL_PASSWORD
    
    WEBHOOK_PLUGIN_NAME="LimeSurveyWebhook"
    WEBHOOK_PLUGIN_VERSION="1.1.0"
    OAUTH2_PLUGIN_NAME="AuthOAuth2"
    OAUTH2_PLUGIN_VERSION="1.5.0"

    echo "Inserting plugin $WEBHOOK_PLUGIN_NAME into the plugins table..."
    "${SIMVA_HOME}/bin/run-command.sh" mysql -u $DB_USER -p"$DB_PASSWORD" -e "
    USE $DB_NAME;
    INSERT INTO \`plugins\` (name, plugin_type, active, priority, version)
    VALUES ('$WEBHOOK_PLUGIN_NAME', 'user', 1, 0, '$WEBHOOK_PLUGIN_VERSION');
    "
    echo "Plugin $WEBHOOK_PLUGIN_NAME has been installed and its settings have been added!"

    echo "Inserting plugin $OAUTH2_PLUGIN_NAME into the plugins table..."
    "${SIMVA_HOME}/bin/run-command.sh" mysql -u $DB_USER -p"$DB_PASSWORD" -e "
    USE $DB_NAME;
    INSERT INTO \`plugins\` (name, plugin_type, active, priority, version)
    VALUES ('$OAUTH2_PLUGIN_NAME', 'user', 1, 0, '$OAUTH2_PLUGIN_VERSION');
    "

    echo "Plugin $OAUTH2_PLUGIN_NAME has been installed and its settings have been added!"
fi