#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Create JSON payload
payload="{\"username\":\"$(echo $SIMVA_API_ADMIN_USERNAME | tr '[:upper:]' '[:lower:]')\",\"password\":\"$SIMVA_API_ADMIN_PASSWORD\"}"
${SIMVA_HOME}/bin/wait-available-with-connection.sh "SIMVA API" "https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/users/login" "$payload" "token" "false"