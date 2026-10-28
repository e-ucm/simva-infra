#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if  [[ ! -e "${SIMVA_CONFIG_HOME}/keycloak/.migration" ]]; then 
    exit 0
fi
if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -lt 18 ]]; then
    echo "Keycloak version is less than 18. Migration needed."
    echo "Please upgrade to a newer keycloak version ( > 18.*.*) before running this script."
    echo "Migration will be performed after the upgrade."
    exit 0
elif [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -lt 26 ]]; then
    echo "Keycloak version is greater than or equal to 18 but less than 26. Migration in progress."
    touch "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress"
else 
    echo 0
fi
