#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN  == "false" ]]; then 
    if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
        if [[ ! -e "${SIMVA_TRAEFIK_SHLINK_CERT_FILE}" ]]; then
            mkcert \
                -cert-file "${SIMVA_TRAEFIK_SHLINK_CERT_FILE}" \
                -key-file "${SIMVA_TRAEFIK_SHLINK_KEY_FILE}" \
                    "${SIMVA_SHLINK_EXTERNAL_DOMAIN}" \
                    "localhost" \
                    "127.0.0.1" \
                    "${SIMVA_HOST_EXTERNAL_IP}"
            chmod ${SIMVA_CERT_FILE_MOD} "${SIMVA_TRAEFIK_SHLINK_KEY_FILE}"
            chmod ${SIMVA_CERT_FILE_MOD} "${SIMVA_TRAEFIK_SHLINK_CERT_FILE}"
            source ${SIMVA_HOME}/bin/check-checksum.sh;
            set +e
            _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHLINK_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_SHLINK_CERT_FILENAME}"
            set -e
        fi
    else
        echo "Please insert your ${SIMVA_TRAEFIK_SHLINK_CERT_FILE} or run using SIMVA_TLS_GENERATE_SELF_SIGNED=true to self generate your certificates."
        exit 1;
    fi
fi