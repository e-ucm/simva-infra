#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
    ["${SIMVA_DATA_HOME}/shlink/data"]="shlink_db"
    ["${SIMVA_DATA_HOME}/shlink/config"]="shlink_config"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"
done

if [[ -d "${SIMVA_DATA_HOME}/shlink/data" ]]; then 
  ${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_DATA_HOME}/shlink"
fi

"${SIMVA_BIN_HOME}/volumectl.sh" exec "shlink_db" "/shlink_db" "
    # Set ownership recursively
    chown -R ${SIMVA_SHLINK_GUID}:${SIMVA_SHLINK_UUID} /shlink_db;

    # # Top-level volume directory
    chmod ${SIMVA_SHLINK_TOP_DIR_MODE} /shlink_db;

    # Directories
    find /shlink_db -type d -print0 | xargs -0 chmod ${SIMVA_SHLINK_DIR_MODE};

    # Files
    find /shlink_db -type f -print0 | xargs -0 chmod ${SIMVA_SHLINK_FILE_MODE};
    ls -lia /shlink_db;
"

if [[ -d "${SIMVA_DATA_HOME}/shlink/config" ]]; then 
  ${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_DATA_HOME}/shlink/config"
fi

"${SIMVA_BIN_HOME}/volumectl.sh" exec "shlink_config" "/shlink_config" "
    # Set ownership recursively
    chown -R ${SIMVA_SHLINK_GUID}:${SIMVA_SHLINK_UUID} /shlink_config;
    
    # Top-level volume directory
    chmod ${SIMVA_SHLINK_TOP_DIR_MODE} /shlink_config;
    
    # Directories
    find /shlink_config -type d -print0 | xargs -0 chmod ${SIMVA_SHLINK_DIR_MODE};

    # Files
    find /shlink_config -type f -print0 | xargs -0 chmod ${SIMVA_SHLINK_FILE_MODE};
    ls -lia /shlink_config;
  "