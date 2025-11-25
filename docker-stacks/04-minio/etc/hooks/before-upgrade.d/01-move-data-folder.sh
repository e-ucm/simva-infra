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

minioFolder="${SIMVA_DATA_HOME}/minio"
format=$(${SIMVA_BIN_HOME}/volumectl.sh exec "minio_data" "/vol" cat "/vol/.minio.sys/format.json" | jq '.format')
if [[ ! -e "$minioFolder/.migration-in-progress-fs-to-xl" ]] && [[ $format == '"fs"' ]]; then
    touch "$minioFolder/.migration-in-progress-fs-to-xl"
    "${SIMVA_BIN_HOME}/volumectl.sh" migrate "minio_data" "minio_mig_data"
fi