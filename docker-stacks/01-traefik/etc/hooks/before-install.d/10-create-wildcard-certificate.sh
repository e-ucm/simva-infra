#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED:-false}" != "true" ]]; then
  exit 0
fi

export CAROOT="${SIMVA_TLS_HOME}/ca"

if [[ ! -e "${CAROOT}/rootCA.pem" ]]; then
    mkcert -install
    chmod a+r ${SIMVA_TLS_HOME}/rootCA-key.pem
    chmod a+r ${SIMVA_TLS_HOME}/rootCA.pem
fi

if [[ ! -e "${SIMVA_TLS_HOME}/traefik.pem" ]]; then
    mkcert \
        -cert-file ${SIMVA_TLS_HOME}/traefik.pem \
        -key-file ${SIMVA_TLS_HOME}/traefik-key.pem \
            "${SIMVA_TRAEFIK_HOST_SUBDOMAIN:-traefik}.${SIMVA_INTERNAL_DOMAIN:-internal.test}" \
            "*.${SIMVA_SSO_HOST_SUBDOMAIN:-sso}.${SIMVA_INTERNAL_DOMAIN:-internal.test}" \
            "*.${SIMVA_LIMESURVEY_HOST_SUBDOMAIN:-limesurvey}.${SIMVA_INTERNAL_DOMAIN:-internal.test}" \
            "*.${SIMVA_EXTERNAL_DOMAIN:-external.test}" \
            "localhost" \
            "127.0.0.1" \
            "${SIMVA_HOST_EXTERNAL_IP}"
    chmod a+r ${SIMVA_TLS_HOME}/traefik-key.pem
    chmod a+r ${SIMVA_TLS_HOME}/traefik.pem
    cp ${SIMVA_TLS_HOME}/traefik.pem ${SIMVA_TLS_HOME}/traefik-fullchain.pem
    cat ${SIMVA_TLS_HOME}/ca/rootCA.pem >> ${SIMVA_TLS_HOME}/traefik-fullchain.pem
    chmod a+r ${SIMVA_TLS_HOME}/traefik-fullchain.pem
    keytool -importcert -trustcacerts -noprompt -storepass ${SIMVA_TRUSTSTORE_PASSWORD} -keystore ${SIMVA_TLS_HOME}/truststore.jks -alias ${SIMVA_TRUSTSTORE_CA_ALIAS} -file ${SIMVA_TLS_HOME}/ca/rootCA.pem 
fi

if [[ ! -e "${SIMVA_TLS_HOME}/dhparam.pem" ]]; then
    openssl dhparam -out "${SIMVA_TLS_HOME}/dhparam.pem" 2048
fi
