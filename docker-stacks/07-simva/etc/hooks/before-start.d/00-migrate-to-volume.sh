#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define folders and corresponding volumes
declare -A folders_volumes=(
    ["${SIMVA_DATA_HOME}/simva/simva-trace-allocator-data"]="simva_trace_allocator_data"
    ["${SIMVA_DATA_HOME}/simva/simva-trace-allocator-logs"]="simva_trace_allocator_logs"
    ["${SIMVA_DATA_HOME}/simva/simva-front-logs"]="simva_front_logs"
    ["${SIMVA_DATA_HOME}/simva/simva-api-logs"]="simva_api_logs"
    ["${SIMVA_DATA_HOME}/simva/storage"]="simva_storage_data"
    ["${SIMVA_DATA_HOME}/simva/mongodb-data"]="simva_mongodb_data"
)

for folder in "${!folders_volumes[@]}"; do
    volume="${folders_volumes[$folder]}"
    "${SIMVA_HOME}/bin/volumectl.sh" migrate "$folder" "$volume"
done