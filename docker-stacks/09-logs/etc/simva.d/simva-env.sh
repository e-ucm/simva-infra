#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export COMPOSE_FILE="docker-compose.dozzle.yml"
if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.portainer.yml"    
fi