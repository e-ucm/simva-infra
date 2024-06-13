#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

#https://doc.traefik.io/traefik/middlewares/http/basicauth/
export SIMVA_TRAEFIK_DASHBOARD_HASHED_PASSWORD=$(docker run --rm httpd:2.4-alpine htpasswd -nbB ${SIMVA_TRAEFIK_DASHBOARD_USER} ${SIMVA_TRAEFIK_DASHBOARD_PASSWORD} | cut -d ":" -f 2)
#https://blog.roberthallam.org/2020/05/generating-a-traefik-nginx-password-hash-without-htpasswd/ not working
#export SIMVA_TRAEFIK_DASHBOARD_HASHED_PASSWORD=$(openssl passwd -apr1 ${SIMVA_TRAEFIK_DASHBOARD_PASSWORD} | sed -E "s:[\$]:\$\$:g")

export COMPOSE_FILE="docker-compose.yml"
if [[ "${SIMVA_ENVIRONMENT}" == "production" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.prod.yml"
elif [[ "${SIMVA_DEV_LOAD_BALANCER}" == "true" ]]; then
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev-lb.yml"
else
    export COMPOSE_FILE="$COMPOSE_FILE:docker-compose.dev.yml"
fi