#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="keycloak"
export RUN_IN_AS_SPECIFIC_USER="root"

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -ge 26 ]]; then 
    "${SIMVA_BIN_HOME}/run-command.sh" '/root/.keycloak/entrypoint.d/docker-startup.sh'
fi