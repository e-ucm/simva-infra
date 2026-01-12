#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -f "$SIMVA_DATA_HOME/simva/migration_sqlite_in_progress" ]]; then
    echo "Migration in progress. Skipping wait availability."
    exit 0
fi

# Create JSON payload
payload="{\"username\":\"$(echo $SIMVA_API_ADMIN_USERNAME | tr '[:upper:]' '[:lower:]')\",\"password\":\"$SIMVA_API_ADMIN_PASSWORD\"}"
${SIMVA_BIN_HOME}/wait-available-with-connection.sh "SIMVA API" "https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/users/login" "$payload" "token" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE"