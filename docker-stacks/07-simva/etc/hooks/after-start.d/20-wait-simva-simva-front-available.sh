#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -f "$SIMVA_DATA_HOME/simva/migration_sqlite_in_progress" ]]; then
    echo "Migration in progress. Skipping wait availability."
    exit 0
fi

${SIMVA_BIN_HOME}/wait-available.sh "SIMVA Front" "https://${SIMVA_EXTERNAL_DOMAIN}/users/login" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE"