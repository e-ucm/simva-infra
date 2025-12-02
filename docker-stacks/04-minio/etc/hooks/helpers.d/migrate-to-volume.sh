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

"${SIMVA_BIN_HOME}/volumectl.sh" exec "minio_data" "/minio" "
    # Set ownership recursively
    chown -R ${SIMVA_MINIO_GUID}:${SIMVA_MINIO_UUID} /minio;
    
    # Top-level volume directory
    chmod ${SIMVA_MINIO_TOP_DIR_MODE} /minio;

    # Directories
    find /minio -type d -print0 | xargs -0 chmod ${SIMVA_MINIO_DIR_MODE};

    # Files
    find /minio -type f -print0 | xargs -0 chmod ${SIMVA_MINIO_FILE_MODE};
  "