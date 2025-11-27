#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

"${SIMVA_BIN_HOME}/wait-available.sh" "TMon" "https://${SIMVA_TMON_DASHBOARD_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" "false" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";

if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
  "${SIMVA_BIN_HOME}/wait-available.sh" "Jupyter" "https://${SIMVA_JUPYTER_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" "false" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";
fi;