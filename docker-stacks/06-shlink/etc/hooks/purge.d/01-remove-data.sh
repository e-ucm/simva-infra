#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/shlink/.initialized" \
    "${SIMVA_DATA_HOME}/shlink/.externaldomain" \
    "${SIMVA_DATA_HOME}/shlink/.version"

"${SIMVA_HOME}/bin/volumectl.sh" delete "shlink_db"
"${SIMVA_HOME}/bin/volumectl.sh" delete "shlink_config"