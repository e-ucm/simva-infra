#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/logs/portainer" \
    "${SIMVA_CONFIG_HOME}/logs/portainer-config" \
    "${SIMVA_CONFIG_HOME}/logs/dozzle-config" 

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/logs/.initialized" \
    "${SIMVA_DATA_HOME}/logs/.externaldomain" \
    "${SIMVA_DATA_HOME}/logs/.version"