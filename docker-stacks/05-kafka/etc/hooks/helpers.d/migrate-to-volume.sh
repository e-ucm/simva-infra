#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
    ["${SIMVA_DATA_HOME}/kafka/data/kafka1/data"]="kafka_data"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "$folder" "$volume"
done

if [[ -d "${SIMVA_DATA_HOME}/kafka/data/kafka1/data" ]]; then 
  "${SIMVA_BIN_HOME}/volumectl.sh" exec "kafka_data" "/kafka_data" "
    # Set ownership recursively (appuser:appuser - 1000:1000)
    chown -R 1000:1000 /kafka_data;

    # Directories -> 755 (rwxr-xr-x)
    find /kafka_data -type d -print0 | xargs -0 chmod 755;

    # Files -> 644 (rw-r--r--)
    find /kafka_data -type f -print0 | xargs -0 chmod 644;
  "
  rm -rf "${SIMVA_DATA_HOME}/kafka/data/kafka1/data"
fi