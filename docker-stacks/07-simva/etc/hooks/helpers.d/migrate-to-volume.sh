#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

simva_storage_data="${SIMVA_DATA_HOME}/simva/storage"
if [[ -e "${SIMVA_DATA_HOME}/simva/simva-backup-storage" ]]; then
    simva_storage_data="${SIMVA_DATA_HOME}/simva/simva-backup-storage"
elif [[ -e "${SIMVA_DATA_HOME}/simva/storage" ]]; then
    simva_storage_data="${SIMVA_DATA_HOME}/simva/storage"
else
    simva_storage_data="${SIMVA_DATA_HOME}/simva/simva-backup-storage"
fi
# Define folders and corresponding volumes
declare -A folders_volumes=(
    ["${SIMVA_DATA_HOME}/simva/simva-trace-allocator-data"]="simva_trace_allocator_data"
    ["${SIMVA_DATA_HOME}/simva/simva-trace-allocator-logs"]="simva_trace_allocator_logs"
    ["${SIMVA_DATA_HOME}/simva/simva-front-logs"]="simva_front_logs"
    ["${SIMVA_DATA_HOME}/simva/simva-api-logs"]="simva_api_logs"
    ["${SIMVA_DATA_HOME}/simva/pumva-logs"]="pumva_logs"
    ["${simva_storage_data}"]="simva_storage_data"
    ["${SIMVA_DATA_HOME}/simva/mongo"]="simva_mongodb_data"
    ["${SIMVA_DATA_HOME}/simva/sqlite"]="simva_sqlite_data"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"
    if [[ -d "$folder" ]]; then
        rm -rf "$folder"
    fi
    if [[ $volume == "simva_mongodb_data" ]]; then 
        # Use MongoDB specific permissions
        guid="${SIMVA_MONGO_DB_GUID}"
        uuid="${SIMVA_MONGO_DB_UUID}"
        # Top directory
        topDirectoryMod="${SIMVA_MONGO_DB_TOP_DIR_MODE}"
        # Directories
        directoryMod="${SIMVA_MONGO_DB_DIR_MODE}"
        # Files
        fileMod="${SIMVA_MONGO_DB_FILE_MODE}"
    else
        # Use Node specific permissions
        guid="${SIMVA_NODE_GUID}"
        uuid="${SIMVA_NODE_UUID}"
        # Top directory
        topDirectoryMod="${SIMVA_NODE_TOP_DIR_MODE}"
        # Directories
        directoryMod="${SIMVA_NODE_DIR_MODE}"
        # Files
        fileMod="${SIMVA_NODE_FILE_MODE}"
    fi
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