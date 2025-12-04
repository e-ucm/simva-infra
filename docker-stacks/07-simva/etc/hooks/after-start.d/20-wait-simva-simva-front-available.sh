#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/wait-available.sh "SIMVA Front" "https://${SIMVA_EXTERNAL_DOMAIN}/users/login" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE"