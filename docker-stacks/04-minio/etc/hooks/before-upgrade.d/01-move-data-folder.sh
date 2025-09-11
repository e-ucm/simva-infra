#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

minioFolder="${SIMVA_DATA_HOME}/minio"
format=$(${SIMVA_HOME}/bin/volumectl.sh exec "minio_data" "/vol" cat "/vol/.minio.sys/format.json" | jq '.format')
if [[ ! -e "$minioFolder/migration-in-progress-fs-to-xl" ]] && [[ $format == '"fs"' ]]; then
    touch "$minioFolder/migration-in-progress-fs-to-xl"
    "${SIMVA_HOME}/bin/volumectl.sh" migrate "minio_data" "minio_mig_data"
fi