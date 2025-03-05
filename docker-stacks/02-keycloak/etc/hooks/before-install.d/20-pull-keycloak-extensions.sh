#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

EXTENSIONS_DIR=${SIMVA_DATA_HOME}/keycloak/extensions

DEPLOYMENT_DIR=${SIMVA_DATA_HOME}/keycloak/deployments
GIT_RELEASE_URL="https://github.com/e-ucm/keycloak-extensions/releases/download/v${KEYCLOAK_EXTENSION_RELEASE}"
if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then
    # (tested in Keycloak 24.0.2)
    SIMVA_EXTENSIONS="es.e-ucm.simva.fullname-attribute-mapper:es.e-ucm.simva.policy-attribute-mapper:es.e-ucm.simva.simva-theme"    
else
    # (tested in Keycloak 10.0.2)
    SIMVA_EXTENSIONS="es.e-ucm.simva.lti-oidc-mapper:es.e-ucm.simva.script-policy-attribute-mapper"
fi

for ext in $SIMVA_EXTENSIONS; do
    ext_jar="${ext}-${SIMVA_EXTENSIONS_VERSION}.jar"
    if [[ ! -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
        wget -q -P $EXTENSIONS_DIR "${GIT_RELEASE_URL}/${ext_jar}"
        shasums="SHA256SUMS-${SIMVA_EXTENSIONS_VERSION}"
        if [[ ! -f "${EXTENSIONS_DIR}/${shasums}" ]]; then
            wget -q -P $EXTENSIONS_DIR -O "${shasums}" "${GIT_RELEASE_URL}/SHA256SUMS"
        fi
        echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -s -
        cp "${EXTENSIONS_DIR}/${ext_jar}" "$DEPLOYMENT_DIR/$ext.jar"
    fi
done

ext="keycloak-events"
ext_jar="${ext}-${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}.jar"
if [[ ! -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
    wget -P $EXTENSIONS_DIR -q "https://github.com/e-ucm/keycloak-events/releases/download/v${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}/${ext_jar}"
    shasums="SHA256SUMS-${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}"
    if [[ ! -f "${EXTENSIONS_DIR}/${shasums}" ]]; then
        wget -q -P $EXTENSIONS_DIR -O "${shasums}" "https://github.com/e-ucm/keycloak-events/releases/download/v${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}/SHA256SUMS"
    fi
    echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -s -
    cp "${EXTENSIONS_DIR}/${ext_jar}" "$DEPLOYMENT_DIR/$ext.jar"
fi

chmod -R 777 $DEPLOYMENT_DIR