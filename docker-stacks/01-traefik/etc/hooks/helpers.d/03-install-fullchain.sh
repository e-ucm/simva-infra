#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}" ]]; then
    cp "${SIMVA_TRAEFIK_CERT_FILE}" "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
    cat "${SIMVA_ROOT_CA_FILE}" >> "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
    chmod a+r "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
    set +e
    source ${SIMVA_HOME}/bin/check-checksum.sh;
    _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_FULLCHAIN_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILENAME}"
    set -e
fi