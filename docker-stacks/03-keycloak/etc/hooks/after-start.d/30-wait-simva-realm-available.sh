#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress" ]]; then 
  if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then
    ${SIMVA_BIN_HOME}/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";
  else 
    ${SIMVA_BIN_HOME}/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/auth/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";
  fi
fi