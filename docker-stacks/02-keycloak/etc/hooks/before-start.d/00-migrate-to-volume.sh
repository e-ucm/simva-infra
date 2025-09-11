#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
  ["${SIMVA_DATA_HOME}/keycloak/mariadb"]="kc_maria_db_data"
  ["${SIMVA_DATA_HOME}/keycloak/mariadb-dump"]="kc_maria_db_backup_data"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_HOME}/bin/volumectl.sh" migrate "$folder" "$volume"
done