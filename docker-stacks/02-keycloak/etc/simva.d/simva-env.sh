#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export COMPOSE_FILE="docker-compose.yml"
if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -gt 18 ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-keycloak-new.yml"
else 
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-keycloak-old.yml"
fi
if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
fi