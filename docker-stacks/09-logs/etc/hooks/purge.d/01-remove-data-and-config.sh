#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/logs/portainer-config" \
    "${SIMVA_CONFIG_HOME}/logs/dozzle-config" 

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/logs/.initialized" \
    "${SIMVA_DATA_HOME}/logs/.externaldomain" \
    "${SIMVA_DATA_HOME}/logs/.version"

"${SIMVA_BIN_HOME}/volumectl.sh" delete "portainer-logs"