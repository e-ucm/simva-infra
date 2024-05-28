#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

passwordhashed=$(docker run --rm httpd:2.4-alpine htpasswd -nbB ${SIMVA_TRAEFIK_DASHBOARD_USER} ${SIMVA_TRAEFIK_DASHBOARD_PASSWORD} | cut -d ":" -f 2)
echo $passwordhashed > "${SIMVA_CONFIG_HOME}/traefik/traefik-password-hashed.txt"