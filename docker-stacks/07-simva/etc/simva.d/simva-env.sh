#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export SIMVA_LIMESURVEY_VERSION_NUMBER=${SIMVA_LIMESURVEY_VERSION%.*}
export COMPOSE_FILE="docker-compose.yml:docker-compose.mongo.yml:docker-compose.mysql.yml"
if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.mongo.yml"
    if [[ ${SIMVA_ENABLE_DEBUG_PROFILING:-false} = true ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.prof.yml"
    else 
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
    fi
else
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
fi