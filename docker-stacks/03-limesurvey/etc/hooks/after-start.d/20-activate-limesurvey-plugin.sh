#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Variable
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"
export RUN_IN_CONTAINER_NAME="limesurvey"

# Step 1: Clear LimeSurvey cache
echo "Clearing LimeSurvey cache..."
"${SIMVA_BIN_HOME}/run-command.sh" rm -rf /var/www/html/tmp/runtime/cache/*

if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/.initialized" ]]; then     
    # Step 2: Insert the Plugins
    export RUN_IN_CONTAINER_NAME="mariadb"  # The name of your MySQL container
    DB_NAME=$SIMVA_LIMESURVEY_MYSQL_DATABASE
    DB_USER=$SIMVA_LIMESURVEY_MYSQL_USER
    DB_PASSWORD=$SIMVA_LIMESURVEY_MYSQL_PASSWORD
    
    if [[ ${SIMVA_LIMESURVEY_VERSION%.*} > 5 ]]; then
        declare -A plugins=(["LimeSurveyWebhook"]=${SIMVA_LIMESURVEY_WEBHOOK_PLUGIN_VERSION} ["AuthOAuth2"]=${SIMVA_LIMESURVEY_AUTHOAUTH2_PLUGIN_VERSION} ["LimeSurveyXAPITracker"]=${SIMVA_LIMESURVEY_XAPITRACKER_PLUGIN_VERSION});
        for key in "${!plugins[@]}"; do
            ext_name=$key
            ext_version=${plugins[$key]}
            echo "Inserting plugin $ext_name into the plugins table..."
            plugin=$("${SIMVA_BIN_HOME}/run-command.sh" mysql -u $DB_USER -p"$DB_PASSWORD" -e "
                USE $DB_NAME;
                SELECT id FROM \`plugins\` WHERE name='$ext_name' AND active=1 and version='$ext_version';");
            echo $plugin;
            if [[ ! $plugin == *"id"* ]]; then 
                "${SIMVA_BIN_HOME}/run-command.sh" mysql -u $DB_USER -p"$DB_PASSWORD" -e "
                USE $DB_NAME;
                INSERT INTO \`plugins\` (name, plugin_type, active, priority, version)
                VALUES ('$ext_name', 'user', 1, 0, '$ext_version');
                "
                echo "Plugin $ext_name has been installed and its settings have been added!"
            else 
                echo "Plugin $ext_name settings have already been added!"
            fi
        done
        #Desactivate AuthSAML
        plugin=$("${SIMVA_BIN_HOME}/run-command.sh" mysql -u $DB_USER -p"$DB_PASSWORD" -e "
                USE $DB_NAME;
                SELECT id FROM \`plugins\` WHERE name='AuthSAML' AND active=1;");
        echo $plugin;
        if [[ $plugin == *"id"* ]]; then 
            "${SIMVA_BIN_HOME}/run-command.sh" mysql -u $DB_USER -p"$DB_PASSWORD" -e "
                USE $DB_NAME;
                UPDATE \`plugins\`
                SET active = 0
                WHERE name = 'AuthSAML';    
            "
        else 
            echo "Plugin AuthSAML is already desactivated!"
        fi
    fi
fi