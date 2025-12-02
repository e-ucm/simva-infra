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
  rm -rf "${SIMVA_DATA_HOME}/kafka/data/kafka1/data"
fi

"${SIMVA_BIN_HOME}/volumectl.sh" exec "kafka_data" "/kafka_data" "
    # Set ownership recursively
    chown -R ${SIMVA_KAFKA_GUID}:${SIMVA_KAFKA_UUID} /kafka_data;

    # Top-level volume directory
    chmod ${SIMVA_KAFKA_TOP_DIR_MODE} /kafka_data;

    # Directories
    find /kafka_data -type d -print0 | xargs -0 chmod ${SIMVA_KAFKA_DIR_MODE};

    # Files
    find /kafka_data -type f -print0 | xargs -0 chmod ${SIMVA_KAFKA_FILE_MODE};
  "