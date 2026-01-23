#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -f "$SIMVA_DATA_HOME/simva/migration_sqlite_in_progress" ]]; then
    echo "Migration in progress. Skipping wait availability."
    exit 0
fi

# Create JSON payload
${SIMVA_BIN_HOME}/wait-available.sh "SIMVA API" "https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/health" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE"