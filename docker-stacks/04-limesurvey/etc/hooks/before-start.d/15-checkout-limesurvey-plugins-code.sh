#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_BIN_HOME}/extension-helper.sh"

# Local deployment builds each plugin from ${SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH}/<PluginName>: fetch missing ones.
if [[ "${SIMVA_LIMESURVEY_PLUGIN_LOCAL_DEPLOYMENT:-false}" == "true" ]]; then
    checkout_local_repo "${SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH}/LimeSurveyWebhook"     "LimeSurveyWebhook"     "v${SIMVA_LIMESURVEY_WEBHOOK_PLUGIN_VERSION}"
    checkout_local_repo "${SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH}/AuthOAuth2"            "AuthOAuth2"            "v${SIMVA_LIMESURVEY_AUTHOAUTH2_PLUGIN_VERSION}"
    checkout_local_repo "${SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH}/LimeSurveyXAPITracker" "LimeSurveyXAPITracker" "v${SIMVA_LIMESURVEY_XAPITRACKER_PLUGIN_VERSION}"
fi
