#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_DATA_HOME}/limesurvey${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH}-data/config"