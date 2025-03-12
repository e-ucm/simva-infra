#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

function __keycloak_login() {
    if [[ ! -f "${SIMVA_TRUSTSTORE_FILE}" ]]; then
        if [[ -f "${SIMVA_ROOT_CA_FILE}" ]]; then
            keytool -importcert -trustcacerts -noprompt \
                -storepass "${SIMVA_TRUSTSTORE_PASSWORD}" \
                -alias "${SIMVA_TRUSTSTORE_CA_ALIAS}" \
                -keystore "${SIMVA_TRUSTSTORE_FILE}" \
                -file "${SIMVA_ROOT_CA_FILE}"
        fi
    fi

    if [[ -f "${SIMVA_TRUSTSTORE_FILE}" ]]; then
        "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kcadm.sh config truststore --trustpass ${SIMVA_TRUSTSTORE_PASSWORD} "/root/.keycloak/certs/$(basename "${SIMVA_TRUSTSTORE_FILE}")"
    fi
    "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kcadm.sh config credentials --server "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" --realm "master" --user ${SIMVA_KEYCLOAK_ADMIN_USER} --password ${SIMVA_KEYCLOAK_ADMIN_PASSWORD}
}

function __list_clients() {
    __keycloak_login
    "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kcadm.sh get clients --fields id,clientId
}

function __get_client() {
    if [[ $# -lt 1 ]]; then
        echo "client 'id' expected";
        exit 1;
    fi
    clientId=$1

    __keycloak_login
    "${SIMVA_HOME}/bin/run-command.sh" /opt/keycloak/bin/kcadm.sh get "clients/${clientId}"
}