#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/wait-available.sh "LRS" "https://${SIMVA_LRS_HOST_SUBDOMAIN:-lrs}.${SIMVA_EXTERNAL_DOMAIN}/admin/ui" "false" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE"