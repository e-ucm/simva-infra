#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/limesurvey/data/etc" \
    "${SIMVA_DATA_HOME}/limesurvey/data/plugins" \
    "${SIMVA_DATA_HOME}/limesurvey/data/tmp"