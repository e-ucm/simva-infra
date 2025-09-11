#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
  ["${SIMVA_DATA_HOME}/limesurvey/mariadb"]="ls_maria_db_data"
  ["${SIMVA_DATA_HOME}/limesurvey/mariadb-dump"]="ls_maria_db_backup_data"
  ["${SIMVA_CONFIG_HOME}/limesurvey/etc"]="ls_etc"
  ["${SIMVA_DATA_HOME}/limesurvey/data/upload"]="ls_upload"
  ["${SIMVA_DATA_HOME}/limesurvey/data/tmp"]="ls_tmp"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_HOME}/bin/volumectl.sh" migrate "$folder" "$volume"
done