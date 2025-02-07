#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x
if [[ "${SIMVA_KAFKA_VERSION}" == "7.8.0" ]]; then
    export COMPOSE_FILE="docker-compose-version-7.yml:docker-compose-minio-client.yml"
    if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
    fi
    # Load the Cluster ID from the file for later use
    export KAFKA_CLUSTER_ID=$(cat ${SIMVA_DATA_HOME}/kafka/clusterid)
else 
    export COMPOSE_FILE="docker-compose.yml:docker-compose-minio-client.yml:20-kafka-connect.yml"
    if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml:10-schema-registry.yml:30-kafka-rest-proxy.yml:99-dev-ui.yml"
    fi
fi