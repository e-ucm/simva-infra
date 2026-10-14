#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_RUSTFS_ENABLE:-false}" == "true" ]]; then
  url="https://${SIMVA_RUSTFS_HOST_SUBDOMAIN:-rustfs}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/health/live"
  name="RustFS"
else 
  url="https://${SIMVA_MINIO_HOST_SUBDOMAIN:-minio}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/minio/health/live"
  name="Minio"
fi

${SIMVA_BIN_HOME}/wait-available.sh "$name" "$url" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";