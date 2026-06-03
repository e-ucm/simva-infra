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
    # Use Node specific permissions
    guid="${SIMVA_NODE_GUID}"
    uuid="${SIMVA_NODE_UUID}"
    # Top directory
    topDirectoryMod="${SIMVA_NODE_TOP_DIR_MODE}"
    # Directories
    directoryMod="${SIMVA_NODE_DIR_MODE}"
    # Files
    fileMod="${SIMVA_NODE_FILE_MODE}"
    "${SIMVA_BIN_HOME}/volumectl.sh" exec "$volume" "/volume_data" "
        # Set ownership recursively
        chown -R $guid:$uuid /volume_data;

        # Top-level volume directory
        chmod $topDirectoryMod /volume_data;

        # Directories
        find /volume_data -type d -print0 | xargs -0 chmod $directoryMod;

        # Files
        find /volume_data -type f -print0 | xargs -0 chmod $fileMod;
        ls -lia /volume_data;
    "
done