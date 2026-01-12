#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export SIMVA_LIMESURVEY_VERSION_NUMBER=${SIMVA_LIMESURVEY_VERSION%.*}
if [[ -f "$SIMVA_DATA_HOME/simva/migration_sqlite_in_progress" ]]; then
    export COMPOSE_FILE="docker-compose.migrate_mongo.yml:docker-compose.mongo.yml"
    if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.sqlite.yml:docker-compose.dev.mongo.yml"
    fi
else
    if [[ -f "$SIMVA_DATA_HOME/simva/sqlite_init" ]]; then
        export COMPOSE_FILE="docker-compose.simva.sqlite.yml:docker-compose.mongo.yml:docker-compose.simva.mongo.yml"
        if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
            export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.sqlite.yml:docker-compose.dev.mongo.yml"
        fi
    else 
        export COMPOSE_FILE="docker-compose.mongo.yml:docker-compose.simva.mongo.yml"
        if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
            export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.mongo.yml"
        fi
    fi
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.yml"
    if [[ "${SIMVA_ENVIRONMENT}" = "development" ]]; then
        if [[ ${SIMVA_ENABLE_DEBUG_PROFILING:-false} = true ]]; then
            export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.prof.yml"
        else 
            export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
        fi
    else
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
    fi
fi