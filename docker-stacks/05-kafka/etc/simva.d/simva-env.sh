#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_KAFKA_VERSION%%.*}" -ge 7 ]]; then
    export COMPOSE_FILE="docker-compose-version-7.yml:docker-compose-minio-client.yml"
    if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev-ui.yml:docker-compose-version-7.dev.yml"
    fi
    # Load the Cluster ID from the file for later use
    export KAFKA_CLUSTER_ID=$(cat ${SIMVA_DATA_HOME}/kafka/.clusterid)
else 
    export COMPOSE_FILE="docker-compose.version-5.yml:docker-compose-minio-client.yml"
    if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev-ui.yml:docker-compose-version-5.dev.yml"
    fi
fi