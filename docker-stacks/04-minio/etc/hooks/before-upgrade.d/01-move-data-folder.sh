#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

minioDataFolder="${SIMVA_DATA_HOME}/minio"
format=$(cat "$minioDataFolder/.minio.sys/format.json" | jq '.format')
if [[ ! -e "$minioDataFolder/migration-in-progress-fs-to-xl" ]] && [[ $format == '"fs"' ]]; then
    mkdir "$minioDataFolder-mig/"
    touch "$minioDataFolder/migration-in-progress-fs-to-xl"
    mv "$minioDataFolder/.minio.sys/" "$minioDataFolder-mig/"
    mv "$minioDataFolder/${SIMVA_TRACES_BUCKET_NAME}/" "$minioDataFolder-mig/"
    mv "$minioDataFolder/minio-initialized" "$minioDataFolder-mig/minio-initialized"
fi