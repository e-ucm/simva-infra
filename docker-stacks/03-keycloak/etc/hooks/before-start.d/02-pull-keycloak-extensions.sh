#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Source the extension helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SIMVA_BIN_HOME}/extension-helper.sh"

EXTENSIONS_DIR="${SIMVA_DATA_HOME}/keycloak/extensions"
DEPLOYMENT_DIR="${SIMVA_DATA_HOME}/keycloak/deployments"
ensure_dir "${EXTENSIONS_DIR}"
ensure_dir "${DEPLOYMENT_DIR}"

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -gt 25 ]]; then
    # (tested in Keycloak 26.1.3)
    SIMVA_EXTENSIONS="es.e-ucm.simva.keycloak.fullname-attribute-mapper es.e-ucm.simva.keycloak.policy-attribute-mapper es.e-ucm.simva.keycloak.simva-theme-v2 es.e-ucm.simva.keycloak.custom-token-auth-spi"
    KEYCLOAK_VERSION=${SIMVA_KEYCLOAK_VERSION%%.*}
else
    if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -gt 18 ]]; then
        # (tested in Keycloak 24.0.2)
        SIMVA_EXTENSIONS="es.e-ucm.simva.keycloak.fullname-attribute-mapper es.e-ucm.simva.keycloak.policy-attribute-mapper es.e-ucm.simva.keycloak.simva-theme es.e-ucm.simva.keycloak.custom-token-auth-spi"
        KEYCLOAK_VERSION=${SIMVA_KEYCLOAK_VERSION%%.*}
    else
        # (tested in Keycloak 10.0.2)
        SIMVA_EXTENSIONS="es.e-ucm.simva.keycloak.lti-oidc-mapper es.e-ucm.simva.keycloak.script-policy-attribute-mapper"        
        KEYCLOAK_VERSION=10
    fi
fi

SIMVA_KEYCLOAK_EXTENSION_LOCAL_DEPLOYMENT="${SIMVA_KEYCLOAK_EXTENSION_LOCAL_DEPLOYMENT:-false}"
SIMVA_KEYCLOAK_EXTENSIONS_LOCAL_PATH="${SIMVA_KEYCLOAK_EXTENSIONS_LOCAL_PATH:-}"

if [[ "${SIMVA_KEYCLOAK_EXTENSION_LOCAL_DEPLOYMENT}" == "true" ]]; then
    echo "Local deployment mode enabled for Keycloak extensions."
    SIMVA_KEYCLOAK_EXTENSIONS_LOCAL_PATH=$(validate_local_path "${SIMVA_KEYCLOAK_EXTENSIONS_LOCAL_PATH}" "SIMVA_KEYCLOAK_EXTENSIONS_LOCAL_PATH")
    
    for ext in $SIMVA_EXTENSIONS; do
        ext_short_name="${ext##*.}"
        build_local_extension "${SIMVA_KEYCLOAK_EXTENSIONS_LOCAL_PATH}" "${ext_short_name}" "${ext}" \
            "${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}" "${DEPLOYMENT_DIR}" "k:${KEYCLOAK_VERSION}"
    done
else
    GIT_RELEASE_URL="https://github.com/e-ucm/keycloak-extensions/releases/download/v${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"
    shasums="SHA256SUMS-KEYCLOAK-EXTENSIONS-${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"
    download_shasums "${EXTENSIONS_DIR}" "${GIT_RELEASE_URL}" "${shasums}"
    
    for ext in $SIMVA_EXTENSIONS; do
        ext_jar="${ext}-keycloak${KEYCLOAK_VERSION}-${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}.jar"
        download_extension "${EXTENSIONS_DIR}" "${DEPLOYMENT_DIR}" "${GIT_RELEASE_URL}" "${shasums}" "${ext}" "${ext_jar}"
    done
fi

# Download keycloak-events extension (always from GitHub)
ext="io.phasetwo.keycloak.keycloak-events"
ext_jar="${ext}-${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}.jar"
GIT_RELEASE_URL_EVENTS="https://github.com/e-ucm/keycloak-events/releases/download/v${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}"
shasums_events="SHA256SUMS-KEYCLOAK-EVENTS-${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}"
download_shasums "${EXTENSIONS_DIR}" "${GIT_RELEASE_URL_EVENTS}" "${shasums_events}"
download_extension "${EXTENSIONS_DIR}" "${DEPLOYMENT_DIR}" "${GIT_RELEASE_URL_EVENTS}" "${shasums_events}" "${ext}" "${ext_jar}"