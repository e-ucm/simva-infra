#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/anaconda/jupyter-config" \
    "${SIMVA_DATA_HOME}/anaconda/notebooks" \
    "${SIMVA_DATA_HOME}/anaconda/packages" \
    "${SIMVA_DATA_HOME}/anaconda/simva-env"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/anaconda/.initialized" \
    "${SIMVA_DATA_HOME}/anaconda/.externaldomain" \
    "${SIMVA_DATA_HOME}/anaconda/.version"