#!/usr/bin/env bash

export COMPOSE_FILE="docker-compose.yml:20-kafka-connect.yml"
if [[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:10-schema-registry.yml:11-schema-registry-ui.yml:21-kafka-connect-ui.yml:30-kafka-rest-proxy.yml:99-dev-ui.yml"
fi