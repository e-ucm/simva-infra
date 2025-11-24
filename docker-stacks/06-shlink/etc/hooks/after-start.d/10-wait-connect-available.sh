#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_HOME}/bin/wait-available.sh "Shlink" "https://${SIMVA_SHLINK_EXTERNAL_DOMAIN}/rest/health" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";
if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
  payload="$SIMVA_TRAEFIK_DASHBOARD_USER:$SIMVA_TRAEFIK_DASHBOARD_PASSWORD"
  ${SIMVA_HOME}/bin/wait-available.sh "Shlink Admin" "https://${SIMVA_SHLINK_ADMIN_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE" $payload;
fi