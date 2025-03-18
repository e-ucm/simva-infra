#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e ""${SIMVA_ROOT_CA_FILE}"" ]]; then
    if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" =="true" ]]; then
        mkdir "${SIMVA_TLS_HOME}/ca"
        mkcert -install
        chmod a+r "${SIMVA_ROOT_CA_KEY_FILE}"
        chmod a+r "${SIMVA_ROOT_CA_FILE}"
    else 
        echo "Please insert your ${SIMVA_ROOT_CA_FILE} or run using ${SIMVA_TLS_GENERATE_SELF_SIGNED}=true to self generate your certificates."
        exit 1;
    fi
fi

if [[ ! -e "${SIMVA_TRAEFIK_CERT_FILE}" ]]; then
    if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
        mkcert \
            -cert-file "${SIMVA_TRAEFIK_CERT_FILE}" \
            -key-file "${SIMVA_TRAEFIK_KEY_FILE}" \
                "${SIMVA_TRAEFIK_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}" \
                "*.${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}" \
                "*.${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}" \
                "*.${SIMVA_EXTERNAL_DOMAIN}" \
                "${SIMVA_EXTERNAL_DOMAIN}" \
                "localhost" \
                "127.0.0.1" \
                "${SIMVA_HOST_EXTERNAL_IP}"
        chmod a+r "${SIMVA_TRAEFIK_KEY_FILE}"
        chmod a+r "${SIMVA_TRAEFIK_CERT_FILE}"
    else 
        echo "Please insert your ${SIMVA_TRAEFIK_CERT_FILE} or run using ${SIMVA_TLS_GENERATE_SELF_SIGNED}=true to self generate your certificates."
        exit 1;
    fi
fi 

if [[ ! -e "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}" ]]; then
    cp "${SIMVA_TRAEFIK_CERT_FILE}" "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
    cat "${SIMVA_ROOT_CA_FILE}" >> "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
    chmod a+r "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
fi 

if [[ ! -e "${SIMVA_TRUSTSTORE_FILE}" ]]; then
    keytool -importcert -trustcacerts -noprompt \
        -storepass ${SIMVA_TRUSTSTORE_PASSWORD} \
        -keystore ${SIMVA_TRUSTSTORE_FILE} \
        -alias ${SIMVA_TRUSTSTORE_CA_ALIAS}  \
        -file ${SIMVA_ROOT_CA_FILE}
fi

if [[ ! -e "${SIMVA_DHPARAM_FILE}" ]]; then
    if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
        openssl dhparam -out "${SIMVA_DHPARAM_FILE}" 2048
    else 
        echo "Please insert your ${SIMVA_DHPARAM_FILE} or run using ${SIMVA_TLS_GENERATE_SELF_SIGNED}=true to self generate your certificates."
        exit 1;
    fi
fi