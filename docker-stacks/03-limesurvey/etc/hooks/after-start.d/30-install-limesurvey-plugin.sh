#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/.initialized" ]]; then 
    # Variable
    PLUGIN_NAME="LimeSuveyStatusWebhookPlugin"
    
    # Step 3: Enable the plugin using LimeSurvey's API (Optional)
    LIMESURVEY_URL="https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/index.php/admin/remotecontrol"

    # Get session key
    SESSION_KEY=$(curl -s --data "method=get_session_key&params={\"username\":\"$SIMVA_LIMESURVEY_ADMIN_USER\",\"password\":\"$SIMVA_LIMESURVEY_ADMIN_PASSWORD\"}" $LIMESURVEY_URL | jq -r '.result')

    # Enable the plugin
    curl -s --data "method=activate_plugin&params={\"sSessionKey\":\"$SESSION_KEY\",\"plugin\":\"$PLUGIN_NAME\"}" $LIMESURVEY_URL

    # Enable the plugin
    curl -s --data "method=set_plugin_settings&params={\"sSessionKey\":\"$SESSION_KEY\",\"sPlugin\":\"$PLUGIN_NAME\",\"aSettings\":{\"sBug\":\"true\",\"sWebhookUrl\":\"$PLUGIN_NAME\"}}" $LIMESURVEY_URL

    # Logout from API session
    curl -s --data "method=release_session_key&params={\"sSessionKey\":\"$SESSION_KEY\"}" $LIMESURVEY_URL

    echo "Plugin $PLUGIN_NAME installed and activated!"

fi