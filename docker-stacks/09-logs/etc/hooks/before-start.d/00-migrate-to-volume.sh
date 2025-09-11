#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
  ["${SIMVA_DATA_HOME}/logs/portainer"]="portainer-logs"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    
    if [[ -d "$folder" ]]; then
        echo "📂 Migrating '$folder' into volume '$volume'..."
        "${SIMVA_HOME}/bin/volumectl.sh" migrate "$folder" "$volume"
        # Optionally remove the folder after migration
        # rm -rf "$folder"
    else
        echo "⚠️  Folder '$folder' does not exist. Creating empty volume '$volume'..."
        "${SIMVA_HOME}/bin/volumectl.sh" create "$volume"
    fi
done