#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_DHPARAM_FILE}" ]]; then
    openssl dhparam -out "${SIMVA_DHPARAM_FILE}" 2048
fi