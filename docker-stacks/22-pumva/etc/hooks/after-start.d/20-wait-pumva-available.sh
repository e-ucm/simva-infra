#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -f "$SIMVA_DATA_HOME/pumva/sqlite_initialisation_in_progress" ]]; then
    echo "Migration in progress. Skipping wait availability."
    exit 0
fi

${SIMVA_BIN_HOME}/wait-available.sh "PUMVA Front" "https://${SIMVA_PUMVA_HOST_SUBDOMAIN:-pumva}.${SIMVA_EXTERNAL_DOMAIN}" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE"