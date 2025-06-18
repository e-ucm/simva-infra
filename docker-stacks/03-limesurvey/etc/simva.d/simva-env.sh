#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export COMPOSE_FILE="docker-compose.yml"
if [[ ${SIMVA_LIMESURVEY_VERSION%.*} > 5 ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-limesurvey-version-sup-5.yml"
    if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
    else 
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
    fi
else 
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-limesurvey-custom-version-4.yml"
fi