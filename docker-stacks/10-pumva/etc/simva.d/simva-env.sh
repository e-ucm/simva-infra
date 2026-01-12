#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ -f "$SIMVA_DATA_HOME/pumva/sqlite_initialisation_in_progress" ]]; then
    export COMPOSE_FILE="docker-compose.init.yml"
    if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.database.dev.yml"
        if [[ $SIMVA_PUMVA_DATABASE_CHECK == "true" ]]; then
            export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.yml:docker-compose.dev.yml"
        fi
    fi
else
    export COMPOSE_FILE="docker-compose.yml"
    if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
    else
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
    fi
fi