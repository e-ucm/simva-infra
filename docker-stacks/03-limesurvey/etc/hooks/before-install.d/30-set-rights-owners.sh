#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_DATA_HOME}/limesurvey/data/tmp/runtime/" ]]; then 
    mkdir "${SIMVA_DATA_HOME}/limesurvey/data/tmp/runtime/"
fi
# Set rights for www-data to Limesurvey data folder
chown -R 33:33 "${SIMVA_DATA_HOME}/limesurvey/data/"
chmod -R 755 "${SIMVA_DATA_HOME}/limesurvey/data/"

chmod -R 755 "${SIMVA_CONFIG_HOME}/limesurvey/etc/"
chown -R 33:33 "${SIMVA_CONFIG_HOME}/limesurvey/etc/"