#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/limesurvey/etc" \
    "${SIMVA_DATA_HOME}/limesurvey/data/etc" \
    "${SIMVA_DATA_HOME}/limesurvey/data/plugins" \
    "${SIMVA_DATA_HOME}/limesurvey/data/tmp" \
    "${SIMVA_DATA_HOME}/limesurvey/data/upload" \
    "${SIMVA_DATA_HOME}/limesurvey/mariadb" \
    "${SIMVA_DATA_HOME}/limesurvey/mariadb-dump" \
    "${SIMVA_DATA_HOME}/limesurvey${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH}-data/config"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/limesurvey/.initialized"\
    "${SIMVA_DATA_HOME}/limesurvey/.externaldomain"\
    "${SIMVA_DATA_HOME}/limesurvey/.version"\
    "${SIMVA_DATA_HOME}/limesurvey/.initializedRemoteControl"