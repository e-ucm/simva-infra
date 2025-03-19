#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/.initialized" ]]; then 
    # Variable
    LIMESURVEY_CONTAINER="limesurvey"
    PLUGIN_NAME="LimeSuveyStatusWebhookPlugin"
    PLUGIN_VERSION="1.0.0"
    PLUGIN_DEST="/var/www/html/plugins/"      # Destination inside the container
    MYSQL_CONTAINER="mariadb"  # The name of your MySQL container
    DB_NAME=$SIMVA_LIMESURVEY_MYSQL_DATABASE
    DB_USER=$SIMVA_LIMESURVEY_MYSQL_USER
    DB_PASSWORD=$SIMVA_LIMESURVEY_MYSQL_PASSWORD

    # Step 2: Set ownership and permissions (adjust user if needed)
    echo "Setting ownership and permissions..."
    docker compose exec "$LIMESURVEY_CONTAINER" chown -R www-data:www-data "$PLUGIN_DEST$PLUGIN_NAME"
    docker compose exec "$LIMESURVEY_CONTAINER" chmod -R 755 "$PLUGIN_DEST$PLUGIN_NAME"

    # Step 3: Clear LimeSurvey cache
    #echo "Clearing LimeSurvey cache..."
    #docker compose exec "$LIMESURVEY_CONTAINER" rm -rf /var/www/html/tmp/runtime/cache/*

    # Step 1: Insert the Plugin
    #echo "Inserting plugin into the plugins table..."
    #docker compose exec -it $MYSQL_CONTAINER mysql -u $DB_USER -p"$DB_PASSWORD" -e "
    #USE $DB_NAME;
    #INSERT INTO \`plugins\` (name, plugin_type, active, priority, version)
    #VALUES ('$PLUGIN_NAME', 'core', 1, 10, '$PLUGIN_VERSION');
    #"

    # Step 2: Get the plugin ID
    #echo "Getting plugin ID..."
    #PLUGIN_ID=$(docker compose exec -it $MYSQL_CONTAINER mysql -u $DB_USER -p"$DB_PASSWORD" -e "USE $DB_NAME; SELECT id FROM \`plugins\` WHERE name = '$PLUGIN_NAME';" | tail -n 1)
    #echo $PLUGIN_ID

    ## Step 3: Insert plugin settings
    #echo "Inserting plugin settings..."
    #docker compose exec -it $MYSQL_CONTAINER mysql -u $DB_USER -p"$DB_PASSWORD" -e "
    #    USE $DB_NAME;
    #    INSERT INTO \`plugin_settings\` (plugin_id, \`key\`, value)
    #    VALUES ($PLUGIN_ID, 'sBug', 'true'),
    #        ($PLUGIN_ID, 'sWebhookUrl', 'https:\\\\\\/\\\\/$SIMVA_SIMVA_API_HOST_SUBDOMAIN.$SIMVA_EXTERNAL_DOMAIN\\\\/limesurvey-completion-webhooks');
    #"

    echo "Plugin $PLUGIN_NAME has been installed and its settings have been added!"
fi