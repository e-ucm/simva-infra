#!/usr/bin/env bash

export COMPOSE_FILE="docker-compose.yml"
if [[ "${SIMVA_ENVIRONMENT:-production}" == "production" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
elif [[ "${SIMVA_DEV_LOAD_BALANCER:-true}" == "true" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev-lb.yml"
else
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
fi
