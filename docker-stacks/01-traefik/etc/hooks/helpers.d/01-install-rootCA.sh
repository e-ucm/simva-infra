#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_ROOT_CA_FILE}" ]]; then
    if [[ ! -d "${SIMVA_ROOT_CA}" ]]; then
        mkdir "${SIMVA_ROOT_CA}"
    fi
    if [[ ! -d "${SIMVA_ROOT_CA}/backup" ]]; then
        mkdir "${SIMVA_ROOT_CA}/backup"
    fi
    mkcert -install
    cp "$(mkcert -CAROOT)/${SIMVA_ROOT_CA_FILENAME}" ${SIMVA_ROOT_CA}/
    cp "$(mkcert -CAROOT)/${SIMVA_ROOT_CA_KEY_FILENAME}" ${SIMVA_ROOT_CA}/
    chmod ${SIMVA_CERT_FILE_MOD} "${SIMVA_ROOT_CA_FILE}"
    cp "${SIMVA_ROOT_CA_FILE}" ${SIMVA_ROOT_CA}/backup/
    cp "${SIMVA_ROOT_CA_KEY_FILE}" ${SIMVA_ROOT_CA}/backup/
    source ${SIMVA_HOME}/bin/check-checksum.sh;
    set +e
    _check_checksum $SIMVA_ROOT_CA "${SIMVA_ROOTCA_SHA256SUMS_FILE}" "${SIMVA_ROOT_CA_FILENAME}"
    set -e
fi