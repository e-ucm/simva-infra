#!/usr/bin/env bash

export COMPOSE_FILE="docker-compose.yml"
if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-keycloak-new.yml"
else 
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose-keycloak-old.yml"
fi
if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
fi