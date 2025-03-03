#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_CONTAINER_TOOLS_HOME}/wait-for" \
    "${SIMVA_PROJECT_DIR}/bin/gomplate" \
    "${SIMVA_PROJECT_DIR}/.simva-initialized" \
    "${SIMVA_PROJECT_DIR}/.vagrant"

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_PROJECT_DIR}/etc/simva.d/backup/"