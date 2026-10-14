#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

${SIMVA_BIN_HOME}/wait-available.sh "Keycloak" "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE"