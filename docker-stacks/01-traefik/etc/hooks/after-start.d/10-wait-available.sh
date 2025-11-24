#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

payload="$SIMVA_TRAEFIK_DASHBOARD_USER:$SIMVA_TRAEFIK_DASHBOARD_PASSWORD"
${SIMVA_HOME}/bin/wait-available.sh "Traefik" "https://${SIMVA_TRAEFIK_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE" "$payload";