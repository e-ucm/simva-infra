#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

#https://blog.roberthallam.org/2020/05/generating-a-traefik-nginx-password-hash-without-htpasswd/
#export SIMVA_TRAEFIK_DASHBOARD_HASHED_APR1_PASSWORD=$(openssl passwd -apr1 ${SIMVA_TRAEFIK_DASHBOARD_PASSWORD} | sed -E "s:[\$]:\$\$:g")
#export SIMVA_TRAEFIK_DASHBOARD_HASHED_APR1_PASSWORD="${SIMVA_TRAEFIK_DASHBOARD_USER}:${SIMVA_TRAEFIK_DASHBOARD_HASHED_APR1_PASSWORD}"
export SIMVA_TRAEFIK_DASHBOARD_HASHED_HTPASSWD_PASSWORD=$(echo ${SIMVA_TRAEFIK_DASHBOARD_PASSWORD} | htpasswd -niB ${SIMVA_TRAEFIK_DASHBOARD_USER})

export COMPOSE_FILE="docker-compose.yml"
if [[ "${SIMVA_ENVIRONMENT}" == "production" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
else
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
    if [[ "${SIMVA_DEV_LOAD_BALANCER}" == "true" ]]; then
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev-lb.yml"
    else
        export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev-nolb.yml"
    fi
fi
