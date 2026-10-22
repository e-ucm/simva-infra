#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -gt 18 ]]; then
    exit 0
fi
touch "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress"
echo "$SIMVA_KEYCLOAK_VERSION" > "${SIMVA_CONFIG_HOME}/keycloak/.migration"