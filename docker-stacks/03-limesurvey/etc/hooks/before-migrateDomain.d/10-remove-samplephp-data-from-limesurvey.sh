#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-file-if-exist.sh "${SIMVA_CONFIG_HOME}/limesurvey/etc/config.php"

${SIMVA_HOME}/bin/purge-folder-contents.sh "${SIMVA_DATA_HOME}/limesurvey${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH}-data/config"