#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source "${SIMVA_BIN_HOME}/check-docker-running.sh"
export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"

export RUN_IN_CONTAINER_NAME="keycloak"
# Check if the container is running
_stop_docker_container_if_running || true

mkdir -p "${SIMVA_CONFIG_HOME}/keycloak"
mkdir -p "${SIMVA_DATA_HOME}/keycloak/deployments"
mkdir -p "${SIMVA_DATA_HOME}/keycloak/extensions"

"${SIMVA_BIN_HOME}/purge-folder-contents.sh" \
    "${SIMVA_DATA_HOME}/keycloak/deployments" || true

# Remove all Keycloak extension checksum files to force fresh download
rm -f "${SIMVA_DATA_HOME}/keycloak/extensions/SHA256SUMS-KEYCLOAK-EXTENSIONS-"* 2>/dev/null || true

# Ensure migration marker exists
touch "${SIMVA_CONFIG_HOME}/keycloak/.migration"