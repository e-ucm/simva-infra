#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
  ${SIMVA_HOME}/bin/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN:-sso}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/realms/${SIMVA_SSO_REALM:-simva}/.well-known/openid-configuration" "true" "false";
else 
  ${SIMVA_HOME}/bin/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN:-sso}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/auth/realms/${SIMVA_SSO_REALM:-simva}/.well-known/openid-configuration" "true" "false";
fi