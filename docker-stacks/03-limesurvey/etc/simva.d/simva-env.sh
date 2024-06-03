#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export COMPOSE_FILE="docker-compose.yml"
if [[ ${SIMVA_LIMESURVEY_VERSION%.*} > 5 ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-limesurvey-new.yml"
else 
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-limesurvey-old.yml"
fi
if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
fi