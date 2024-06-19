#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
    export COMPOSE_FILE="docker-compose.yml"
fi