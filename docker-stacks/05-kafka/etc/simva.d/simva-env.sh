#!/usr/bin/env bash

export COMPOSE_FILE="docker-compose.yml:20-kafka-connect.yml"
if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml:10-schema-registry.yml:30-kafka-rest-proxy.yml:99-dev-ui.yml"
fi