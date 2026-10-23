#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_CONTAINER_TOOLS_HOME}/wait-for" \
    "${SIMVA_PROJECT_DIR}/bin/gomplate" \
    "${SIMVA_DATA_HOME}/.simva-initialized"
