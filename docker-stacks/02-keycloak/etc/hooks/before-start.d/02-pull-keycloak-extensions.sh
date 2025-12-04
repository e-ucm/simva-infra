#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

EXTENSIONS_DIR="${SIMVA_DATA_HOME}/keycloak/extensions"
if [[ ! -d "${EXTENSIONS_DIR}" ]]; then
    mkdir "${EXTENSIONS_DIR}"
fi

DEPLOYMENT_DIR="${SIMVA_DATA_HOME}/keycloak/deployments"
if [[ ! -d "${DEPLOYMENT_DIR}" ]]; then
    mkdir "${DEPLOYMENT_DIR}"
fi
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

pushd "${EXTENSIONS_DIR}"

GIT_RELEASE_URL="https://github.com/e-ucm/keycloak-extensions/releases/download/v${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"
shasums="SHA256SUMS-KEYCLOAK-EXTENSIONS-${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}"
wget -q -O "${EXTENSIONS_DIR}/${shasums}" "${GIT_RELEASE_URL}/SHA256SUMS"
for ext in $SIMVA_EXTENSIONS; do
    ext_jar="${ext}-keycloak${KEYCLOAK_VERSION}-${SIMVA_KEYCLOAK_EXTENSIONS_VERSION}.jar"
    if [[ -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
        echo "Extension ${ext_jar} already downloaded."
        echo "Verifying checksum..."
        set +e
        echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -
        res=$?
        set -e
        if [[ $res -eq 0 ]]; then
            echo "Checksum valid."
            continue
        else
            echo "Checksum invalid. Re-downloading ${ext_jar}..."
            rm -f "${EXTENSIONS_DIR}/${ext_jar}"
        fi
    fi 
    if [[ ! -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
        echo "Downloading extension ${ext_jar}..."
        wget -q -P ${EXTENSIONS_DIR} "${GIT_RELEASE_URL}/${ext_jar}"
        echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -
    fi
    cp "${EXTENSIONS_DIR}/${ext_jar}" "${DEPLOYMENT_DIR}/${ext}.jar"
done

ext="io.phasetwo.keycloak.keycloak-events"
ext_jar="${ext}-${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}.jar"
shasums="SHA256SUMS-KEYCLOAK-EVENTS-${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}"
wget -q -O "${EXTENSIONS_DIR}/${shasums}" "https://github.com/e-ucm/keycloak-events/releases/download/v${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}/SHA256SUMS"
if [[ -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
    echo "Extension ${ext_jar} already downloaded."
    echo "Verifying checksum..."
    set +e
    echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -
    res=$?
    set -e
    if [[ $res -eq 0 ]]; then
        echo "Checksum valid."
    else
        echo "Checksum invalid. Re-downloading ${ext_jar}..."
        rm -f "${EXTENSIONS_DIR}/${ext_jar}"
    fi
fi
if [[ ! -f "${EXTENSIONS_DIR}/${ext_jar}" ]]; then
    wget -q -P ${EXTENSIONS_DIR} "https://github.com/e-ucm/keycloak-events/releases/download/v${SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION}/${ext_jar}"
    echo "$(cat "${EXTENSIONS_DIR}/${shasums}"  | grep "${ext_jar}" | cut -d' ' -f1) ${ext_jar}" | sha256sum -c -w -
fi
cp "${EXTENSIONS_DIR}/${ext_jar}" "${DEPLOYMENT_DIR}/${ext}.jar"
popd