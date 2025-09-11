#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

minioFolder="${SIMVA_DATA_HOME}/minio"
if [[ -e "$minioFolder/migration-in-progress-fs-to-xl" ]]; then 
    rm "$minioFolder/migration-in-progress-fs-to-xl"
fi 
"${SIMVA_HOME}/bin/volumectl.sh" delete "minio_mig_data"