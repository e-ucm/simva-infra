#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

mkdir -p "${SIMVA_CONFIG_HOME}/keycloak"

# Mark migration and remove previously deployed extensions to force redeploy on upgrade
echo "$SIMVA_KEYCLOAK_VERSION" > "${SIMVA_CONFIG_HOME}/keycloak/.migration"

if [[ -d "${SIMVA_DATA_HOME}/keycloak/deployments" ]]; then
    "${SIMVA_BIN_HOME}/purge-folder-contents.sh" "${SIMVA_DATA_HOME}/keycloak/deployments" || true
fi

if [[ -d "${SIMVA_DATA_HOME}/keycloak/extensions" ]]; then
    rm -f "${SIMVA_DATA_HOME}/keycloak/extensions/SHA256SUMS-KEYCLOAK-EXTENSIONS-"* || true
fi

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