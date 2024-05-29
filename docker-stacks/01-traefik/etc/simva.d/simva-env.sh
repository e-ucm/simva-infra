#!/usr/bin/env bash

export SIMVA_TRAEFIK_DASHBOARD_HASHED_PASSWORD=$(docker run --rm httpd:2.4-alpine htpasswd -nbB ${SIMVA_TRAEFIK_DASHBOARD_USER} ${SIMVA_TRAEFIK_DASHBOARD_PASSWORD} | cut -d ":" -f 2)

export COMPOSE_FILE="docker-compose.yml"
if [[ "${SIMVA_ENVIRONMENT}" == "production" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
elif [[ "${SIMVA_DEV_LOAD_BALANCER}" == "true" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev-lb.yml"
else
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
fi