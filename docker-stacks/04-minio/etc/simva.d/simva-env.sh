#!/usr/bin/env bash

export COMPOSE_FILE="docker-compose.yml"

# Disabled as mcs has been replaced by mc and is already included in docker-compose

#if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
#    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
#fi