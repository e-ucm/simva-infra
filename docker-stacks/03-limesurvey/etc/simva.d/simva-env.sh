#!/usr/bin/env bash

export COMPOSE_FILE="docker-compose.yml"
if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
fi