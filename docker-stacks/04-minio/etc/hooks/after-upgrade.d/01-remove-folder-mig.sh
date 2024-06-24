#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

minioDataFolder="${SIMVA_DATA_HOME}/minio"
if [[ -e "$minioDataFolder/migration-in-progress-fs-to-xl" ]]; then 
    rm "$minioDataFolder/migration-in-progress-fs-to-xl"
fi 
rm -rf "$minioDataFolder-mig/"