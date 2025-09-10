#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e ${SIMVA_DATA_HOME}/simva/storage ]]; then 
    mkdir -p ${SIMVA_DATA_HOME}/simva/storage
fi
chmod a+w ${SIMVA_DATA_HOME}/simva/storage