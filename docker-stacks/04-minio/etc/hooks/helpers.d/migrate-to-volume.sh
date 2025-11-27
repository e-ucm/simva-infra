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
  "${SIMVA_BIN_HOME}/volumectl.sh" exec "minio_data" "/minio" "
    # Set ownership recursively
    chown -R 1000:1000 /minio;
    
    # Directories -> 755 (rwxr-xr-x)
    find /minio -type d -print0 | xargs -0 chmod 755;

    # Files -> 644 (rw-r--r--)
    find /minio -type f -print0 | xargs -0 chmod 644;
  "
  ${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_DATA_HOME}/minio"
fi