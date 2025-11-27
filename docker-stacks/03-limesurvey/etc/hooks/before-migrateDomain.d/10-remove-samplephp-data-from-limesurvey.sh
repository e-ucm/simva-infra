#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-file-if-exist.sh "${SIMVA_CONFIG_HOME}/limesurvey/etc/config.php"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/limesurvey/.initialized"\
    "${SIMVA_DATA_HOME}/limesurvey/.initializedRemoteControl"
