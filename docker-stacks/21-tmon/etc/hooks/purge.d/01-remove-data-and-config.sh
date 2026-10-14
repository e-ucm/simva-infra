#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/tmon/t-mon/" \
    "${SIMVA_DATA_HOME}/anaconda/jupyter-config" \
    "${SIMVA_DATA_HOME}/anaconda/notebooks" \
    "${SIMVA_DATA_HOME}/anaconda/packages" \
    "${SIMVA_DATA_HOME}/anaconda/simva-env"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/tmon/.initialized" \
    "${SIMVA_DATA_HOME}/tmon/.externaldomain" \
    "${SIMVA_DATA_HOME}/tmon/.version" \
    "${SIMVA_DATA_HOME}/tmon/tmon-sha256sums" \
    "${SIMVA_TMON_GIT_REPO}/clients_secrets.json"