#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
  ["${SIMVA_DATA_HOME}/minio"]="minio_data"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"
done

if [[ -d "${SIMVA_DATA_HOME}/minio" ]]; then 
  ${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_DATA_HOME}/minio"
fi

if [[ "${SIMVA_RUSTFS_ENABLE:-false}" == "true" ]]; then
    "${SIMVA_BIN_HOME}/volumectl.sh" exec "minio_data" "/rustfs" "
    # Set ownership recursively
    chown -R ${SIMVA_RUSTFS_GUID}:${SIMVA_RUSTFS_UUID} /rustfs;
    
    # Top-level volume directory
    chmod ${SIMVA_RUSTFS_TOP_DIR_MODE} /rustfs;

    # Directories
    find /rustfs -type d -print0 | xargs -0 chmod ${SIMVA_RUSTFS_DIR_MODE};

    # Files
    find /rustfs -type f -print0 | xargs -0 chmod ${SIMVA_RUSTFS_FILE_MODE};
    ls -lia /rustfs;
"
fi