#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e ""${SIMVA_ROOT_CA_FILE}"" ]]; then
    if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
        if [[ ! -d "${SIMVA_ROOT_CA}" ]]; then
            mkdir "${SIMVA_ROOT_CA}"
        fi
        if [[ ! -d "${SIMVA_ROOT_CA}/backup" ]]; then
            mkdir "${SIMVA_ROOT_CA}/backup"
        fi
        mkcert -install
        cp "$(mkcert -CAROOT)/${SIMVA_ROOT_CA_FILENAME}" ${SIMVA_ROOT_CA}/
        cp "$(mkcert -CAROOT)/${SIMVA_ROOT_CA_KEY_FILENAME}" ${SIMVA_ROOT_CA}/
        chmod a+r "${SIMVA_ROOT_CA_FILE}"
        cp "${SIMVA_ROOT_CA_FILE}" ${SIMVA_ROOT_CA}/backup/
        cp "${SIMVA_ROOT_CA_KEY_FILE}" ${SIMVA_ROOT_CA}/backup/
        set +e
        source ${SIMVA_HOME}/bin/check-checksum.sh;
        _check_checksum $SIMVA_ROOT_CA "${SIMVA_ROOTCA_SHA256SUMS_FILE}" "${SIMVA_ROOT_CA_FILENAME}"
        set -e
    else
        echo "Please insert your ${SIMVA_ROOT_CA_FILE} and ${SIMVA_ROOT_CA_KEY_FILE} or run using SIMVA_TLS_GENERATE_SELF_SIGNED=true to self generate your certificates."
        exit 1;
    fi
fi