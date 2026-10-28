#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -gt 18 ]]; then 
    source "${HELPERS_STACK_HOME}/realm-export-volume.sh"
    __realm_export_volume_prepare
    # The host folder holds the migration markers and the post-processed realm files.
    mkdir -p "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export"
fi
