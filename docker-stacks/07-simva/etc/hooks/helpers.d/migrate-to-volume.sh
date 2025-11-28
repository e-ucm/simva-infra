#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

simva_storage_data="${SIMVA_DATA_HOME}/simva/storage"
if [[ -e "${SIMVA_DATA_HOME}/simva/simva-backup-storage" ]]; then
    simva_storage_data="${SIMVA_DATA_HOME}/simva/simva-backup-storage"
else if [[ -e "${SIMVA_DATA_HOME}/simva/storage" ]]; then
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
    ["${simva_storage_data}"]="simva_storage_data"
    ["${SIMVA_DATA_HOME}/simva/mongo"]="simva_mongodb_data"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"

    if [[ -d "$folder" ]]; then 
        if [[ $volume == "simva_mongodb_data" ]]; then 
            ownership="999:999" #"mongodb:mongodb" // "999:999" 
            # Directories -> 700 (rwx------)
            directoryMod="700"
            # Files -> 600 (rw-------)
            fileMod="600"
        else
            ownership="1000:1000" ##"node:node" // "1000:1000"
            # Directories -> 775 (drwxrwxr-x)
            directoryMod="775"
            # Files -> 664 (rw-rw-r--)
            fileMod="664"
        fi
        "${SIMVA_BIN_HOME}/volumectl.sh" exec "$volume" "/volume_data" "
            # Set ownership recursively
            chown -R $ownership /volume_data;

            # Directories -> 755 (rwxr-xr-x)
            find /volume_data -type d -print0 | xargs -0 chmod $directoryMod;

            # Files -> 644 (rw-r--r--)
            find /volume_data -type f -print0 | xargs -0 chmod $fileMod;
        "
        rm -rf "$folder"
    fi
done