#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source ${SIMVA_HOME}/bin/check-checksum.sh;

set +e
_check_checksum $SIMVA_ROOT_CA "${SIMVA_DATA_HOME}/traefik/rootca-sha256sums" "rootCA.pem"
ret=$?
set -e
echo $ret
if [[ $ret != 0 ]]; then
    if [[ -e "${SIMVA_DATA_HOME}/traefik/.initialized" ]]; then
        read -p "Are you sure that the root CA has been updated ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        cp "${SIMVA_TRAEFIK_CERT_FILE}" "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
        cat "${SIMVA_ROOT_CA_FILE}" >> "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
        chmod a+r "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
        if [[ $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN  == "false" ]]; then 
            cp "${SIMVA_TRAEFIK_SHLINK_CERT_FILE}" "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}"
            cat "${SIMVA_ROOT_CA_FILE}" >> "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}"
            chmod a+r "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}"
        fi
    fi
fi