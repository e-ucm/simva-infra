#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/wait-available.sh "Limesurvey" "https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/admin/authentication/sa/login" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";
