#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

echo "$SIMVA_KEYCLOAK_VERSION" > "${SIMVA_CONFIG_HOME}/keycloak/.migration"
if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -lt 18 ]]; then
    echo "Keycloak version is less than 18. Migration needed."
    echo "Please upgrade to a newer keycloak version ( > 18.*.*) before running this script."
    echo "Migration will be performed after the upgrade."
    exit 0
elif [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -lt 26 ]]; then
    echo "Keycloak version is greater than or equal to 18 but less than 26. Migration needed."
    touch "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress"
    exit 0
else 
    echo "Keycloak version is greater than or equal to 26. No migration needed."
    echo 0
fi