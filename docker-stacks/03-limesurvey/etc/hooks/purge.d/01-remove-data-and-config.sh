#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/limesurvey/etc" \
    "${SIMVA_DATA_HOME}/limesurvey/data/plugins" \
    "${SIMVA_DATA_HOME}/limesurvey${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH}-data/config"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_DATA_HOME}/limesurvey/.initialized"\
    "${SIMVA_DATA_HOME}/limesurvey/.externaldomain"\
    "${SIMVA_DATA_HOME}/limesurvey/.version"\
    "${SIMVA_DATA_HOME}/limesurvey/.initializedRemoteControl"

"${SIMVA_HOME}/bin/volumectl.sh" delete "ls_maria_db_data"
"${SIMVA_HOME}/bin/volumectl.sh" delete "ls_maria_db_backup_data"
"${SIMVA_HOME}/bin/volumectl.sh" delete "ls_etc"
"${SIMVA_HOME}/bin/volumectl.sh" delete "ls_upload"
"${SIMVA_HOME}/bin/volumectl.sh" delete "ls_tmp"