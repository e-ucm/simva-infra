#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

gomplate \
    -f "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf-template/traefik.toml" \
    -o "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/traefik.toml"
 
 chmod -R 777 "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/"