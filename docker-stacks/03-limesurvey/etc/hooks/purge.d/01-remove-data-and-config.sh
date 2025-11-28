#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/purge-folder-contents.sh \
    "${SIMVA_CONFIG_HOME}/limesurvey/etc" \
    "${SIMVA_DATA_HOME}/limesurvey/data/plugins" \
    "${SIMVA_DATA_HOME}/limesurvey/plugins"

${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_CONFIG_HOME}/limesurvey/data.dev.yml"\
    "${SIMVA_CONFIG_HOME}/limesurvey/data.prod.yml"\
    "${SIMVA_CONFIG_HOME}/limesurvey/simva-env.sh"\
    "${SIMVA_DATA_HOME}/limesurvey/.initialized"\
    "${SIMVA_DATA_HOME}/limesurvey/.externaldomain"\
    "${SIMVA_DATA_HOME}/limesurvey/.version"\
    "${SIMVA_DATA_HOME}/limesurvey/.initializedRemoteControl" \
    "${SIMVA_DATA_HOME}/limesurvey/.initializedSSL" \
    "${SIMVA_DATA_HOME}/limesurvey/limesurvey-docker-sha256sums"

"${SIMVA_BIN_HOME}/volumectl.sh" delete "ls_maria_db_data"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "ls_maria_db_backup_data"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "ls_upload"
"${SIMVA_BIN_HOME}/volumectl.sh" delete "ls_tmp"
