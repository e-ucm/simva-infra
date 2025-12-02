#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN  == "false" ]]; then 
    if [[ ! -e "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}" ]]; then
        cp "${SIMVA_TRAEFIK_SHLINK_CERT_FILE}" "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}"
        cat "${SIMVA_ROOT_CA_FILE}" >> "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}"
        chmod ${SIMVA_CERT_FILE_MOD} "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}"
        source ${SIMVA_HOME}/bin/check-checksum.sh;
        set +e
        _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILENAME}"
        set -e
    fi
fi