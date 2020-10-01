#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED:-false}" != "true" ]]; then
  exit 0
fi

TRUSTSTORE_PASSWORD='changeit'
TRUSTSTORE_CA_ALIAS='simvaCA'

export CAROOT="${SIMVA_TLS_HOME}/ca"

if [[ ! -e "${CAROOT}/rootCA.pem" ]]; then
    mkcert -install
fi

if [[ ! -e "${SIMVA_TLS_HOME}/traefik.pem" ]]; then
    mkcert \
        -cert-file ${SIMVA_TLS_HOME}/traefik.pem \
        -key-file ${SIMVA_TLS_HOME}/traefik-key.pem \
            "traefik.${SIMVA_INTERNAL_DOMAIN}" \
            "*.${SIMVA_EXTERNAL_DOMAIN}" \
            "*.keycloak.${SIMVA_EXTERNAL_DOMAIN}" \
            "*.limesurvey.${SIMVA_EXTERNAL_DOMAIN}" \
            "*.app.${SIMVA_EXTERNAL_DOMAIN}" \
            "localhost" \
            "127.0.0.1" \
            "${SIMVA_HOST_EXTERNAL_IP}"
    cp ${SIMVA_TLS_HOME}/traefik.pem ${SIMVA_TLS_HOME}/traefik-fullchain.pem
    cat ${SIMVA_TLS_HOME}/ca/rootCA.pem >> ${SIMVA_TLS_HOME}/traefik-fullchain.pem
    keytool -importcert -trustcacerts -noprompt -storepass ${TRUSTSTORE_PASSWORD} -keystore ${SIMVA_TLS_HOME}/truststore.jks -alias ${TRUSTSTORE_CA_ALIAS} -file ${SIMVA_TLS_HOME}/ca/rootCA.pem 
fi

if [[ ! -e "${SIMVA_TLS_HOME}/dhparam.pem" ]]; then
    openssl dhparam -out "${SIMVA_TLS_HOME}/dhparam.pem" 2048
fi
