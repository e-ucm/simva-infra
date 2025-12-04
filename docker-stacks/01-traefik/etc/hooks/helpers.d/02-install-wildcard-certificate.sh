#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

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
        chmod ${SIMVA_CERT_FILE_MOD} "${SIMVA_TRAEFIK_KEY_FILE}"
        chmod ${SIMVA_CERT_FILE_MOD} "${SIMVA_TRAEFIK_CERT_FILE}"
        source ${SIMVA_HOME}/bin/check-checksum.sh;
        set +e
        _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_CERT_FILENAME}"
        set -e
    else 
        echo "Please insert your cert file at '${SIMVA_TRAEFIK_CERT_FILE}' and key file at '${SIMVA_TRAEFIK_KEY_FILE}' or run using SIMVA_TLS_GENERATE_SELF_SIGNED=true to self generate your certificates."
        exit 1;
    fi
fi