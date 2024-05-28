#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/wait-available.sh "Minio" "https://${SIMVA_MINIO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/minio/health/live" "true" "false";