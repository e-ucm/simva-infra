#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

payload="$SIMVA_TRAEFIK_DASHBOARD_USER:$SIMVA_TRAEFIK_DASHBOARD_PASSWORD"
${SIMVA_HOME}/bin/wait-available.sh "Dozzle" "https://${SIMVA_DOZZLE_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/" "true" "$SIMVA_ROOT_CA_FILE" "$payload";

if [[ "${SIMVA_ENVIRONMENT}" == "development" ]]; then
  ${SIMVA_HOME}/bin/wait-available.sh "Portainer" "https://${SIMVA_PORTAINER_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" "true" "$SIMVA_ROOT_CA_FILE" "$payload";
fi;