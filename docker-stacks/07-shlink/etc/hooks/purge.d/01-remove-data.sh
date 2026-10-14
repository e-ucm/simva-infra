#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/shlink/.initialized" \
    "${SIMVA_DATA_HOME}/shlink/.externaldomain" \
    "${SIMVA_DATA_HOME}/shlink/.version"

"${SIMVA_BIN_HOME}/volumectl.sh" delete "shlink_db"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "shlink_config"