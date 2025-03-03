#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/wait-available.sh "Minio" "https://${SIMVA_MINIO_HOST_SUBDOMAIN:-minio}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/minio/health/live" "true" "false";

echo "Checking container Minio Client..."
while [[ ! $(docker ps --format '{{.Names}}' | grep "mc") == "" ]]; do
    mcContainer=$(docker ps --format '{{.Names}}' | grep "mc")
    echo "Container $mcContainer is still running wait until script finish."
    sleep ${SIMVA_WAIT_TIME};
done
echo "Container Minio Client finished his work."