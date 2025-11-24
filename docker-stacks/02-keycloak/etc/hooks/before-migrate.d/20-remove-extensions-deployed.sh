#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_HOME}/bin/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"

export RUN_IN_CONTAINER_NAME="keycloak"
# Check if the container is running
_stop_docker_container_if_running

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/keycloak/deployments"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/keycloak/extensions/SHA256SUMS-KEYCLOAK-EXTENSIONS-${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"