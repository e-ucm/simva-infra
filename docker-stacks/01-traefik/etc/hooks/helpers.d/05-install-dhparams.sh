#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_DHPARAM_FILE}" ]]; then
    if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
        openssl dhparam -out "${SIMVA_DHPARAM_FILE}" 2048
    else 
        echo "Please insert your ${SIMVA_DHPARAM_FILE} or run using SIMVA_TLS_GENERATE_SELF_SIGNED=true to self generate your certificates."
        exit 1;
    fi
fi