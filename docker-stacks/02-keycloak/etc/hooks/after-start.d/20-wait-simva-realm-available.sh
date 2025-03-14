#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
  ${SIMVA_HOME}/bin/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration" "true" "false";
fi