#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

EXTENSIONS_DIR="${SIMVA_DATA_HOME}/keycloak/extensions"
if [[ ! -d "${EXTENSIONS_DIR}" ]]; then
    mkdir "${EXTENSIONS_DIR}"
fi

DEPLOYMENT_DIR="${SIMVA_DATA_HOME}/keycloak/deployments"
if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then
    # (tested in Keycloak 24.0.2)
    SIMVA_EXTENSIONS="es.e-ucm.simva.keycloak.fullname-attribute-mapper es.e-ucm.simva.keycloak.policy-attribute-mapper es.e-ucm.simva.keycloak.simva-theme" # es.e-ucm.simva.keycloak.custom-token-auth-spi"
else
    # (tested in Keycloak 10.0.2)
    SIMVA_EXTENSIONS="es.e-ucm.simva.keycloak.lti-oidc-mapper es.e-ucm.simva.keycloak.script-policy-attribute-mapper"
fi

pushd "${EXTENSIONS_DIR}"

GIT_RELEASE_URL="https://github.com/e-ucm/keycloak-extensions/releases/download/v${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"
for ext in $SIMVA_EXTENSIONS; do
    ext_jar="${ext}-${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}.jar"
    if [[ ! -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
        wget -q -P "${EXTENSIONS_DIR}" "${GIT_RELEASE_URL}/${ext_jar}"
        chmod 777 "${EXTENSIONS_DIR}/${ext_jar}"
        shasums="SHA256SUMS-KEYCLOAK-EXTENSIONS-${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"
        if [[ ! -f "${EXTENSIONS_DIR}/${shasums}" ]]; then
            wget -q -O "${EXTENSIONS_DIR}/${shasums}" "${GIT_RELEASE_URL}/SHA256SUMS"
        fi
        echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -
        cp "${EXTENSIONS_DIR}/${ext_jar}" "${DEPLOYMENT_DIR}/${ext}.jar"
    fi
done

ext="keycloak-events"
ext_jar="${ext}-${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}.jar"
if [[ ! -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
    wget -q -P ${EXTENSIONS_DIR} "https://github.com/e-ucm/keycloak-events/releases/download/v${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}/${ext_jar}"
    shasums="SHA256SUMS-KEYCLOAK-EVENTS-${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}"
    if [[ ! -f "${EXTENSIONS_DIR}/${shasums}" ]]; then
        wget -q -O "${EXTENSIONS_DIR}/${shasums}" "https://github.com/e-ucm/keycloak-events/releases/download/v${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}/SHA256SUMS"
    fi
    echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -s -
    cp "${EXTENSIONS_DIR}/${ext_jar}" "${DEPLOYMENT_DIR}/${ext}.jar"
fi
popd