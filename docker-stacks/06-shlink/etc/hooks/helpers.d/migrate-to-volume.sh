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
  "${SIMVA_BIN_HOME}/volumectl.sh" exec "shlink_db" "/shlink_db" "
    # Set ownership recursively
    chown -R 1001:1001 /shlink_db;

    # Directories -> 755 (rwxr-xr-x)
    find /shlink_db -type d -print0 | xargs -0 chmod 755;

    # Files -> 644 (rw-r--r--)
    find /shlink_db -type f -print0 | xargs -0 chmod 644;
  "
  ${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_DATA_HOME}/shlink"
fi

if [[ -d "${SIMVA_DATA_HOME}/shlink/config" ]]; then 
  "${SIMVA_BIN_HOME}/volumectl.sh" exec "shlink_config" "/shlink_config" "
    # Set ownership recursively
    chown -R 1001:1001 /shlink_config;

    # Directories -> 755 (rwxr-xr-x)
    find /shlink_config -type d -print0 | xargs -0 chmod 755;

    # Files -> 644 (rw-r--r--)
    find /shlink_config -type f -print0 | xargs -0 chmod 644;
  "
  ${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_DATA_HOME}/shlink/config"
fi