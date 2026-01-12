#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
    ["${SIMVA_DATA_HOME}/pumva/sqlite"]="pumva_sqlite_data"
    ["${SIMVA_DATA_HOME}/pumva/logs"]="pumva_logs"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"
    if [[ -d "$folder" ]]; then
        rm -rf "$folder"
    fi
done