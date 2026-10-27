#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

set +e
KEYCLOAK_REALM_PATH=""
if [ -n "${SIMVA_KEYCLOAK_VERSION:-}" ]; then
  KEYCLOAK_MAJOR=$(echo "${SIMVA_KEYCLOAK_VERSION}" | cut -d. -f1)
  if [ "${KEYCLOAK_MAJOR}" -lt 26 ] 2>/dev/null; then
    KEYCLOAK_REALM_PATH="/auth"
  else
    KEYCLOAK_REALM_PATH=""
  fi
else
  # Fallback: try /auth first is not possible here; default to / for modern
  KEYCLOAK_REALM_PATH=""
fi
/bin/wait-available.sh "Keycloak SIMVA REALM" "${SIMVA_SSO_PROTOCOL}://${SIMVA_SSO_HOST}:${SIMVA_SSO_PORT}${KEYCLOAK_REALM_PATH}/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration" "true" "${NODE_EXTRA_CA_CERTS}";
ret=$?
set -e
echo $ret

if [[ $ret != 0 ]]; then 
  exit 1
fi

set +e
/bin/wait-available.sh 'SIMVA API' "${SIMVA_PROTOCOL}://${SIMVA_HOST}:${SIMVA_PORT}/health" true ${NODE_EXTRA_CA_CERTS};
ret=$?
set -e
echo $ret

if [[ $ret == 0 ]]; then 
  cd "/app"

  #start trace allocator
  echo "${NODE_ENV}"
  if [[ "${NODE_ENV}" == "development" ]]; then
    if [[ "${ENABLE_DEBUG_PROFILING:-false}" == "true" ]]; then
      if [[ ! -e ${PROFILING_FOLDER} ]]; then 
        mkdir -p ${PROFILING_FOLDER}
        chmod -R ${SIMVA_NODE_DIR_MODE} ${PROFILING_FOLDER}
      fi
      rm -rf ./node_trace.*.log
      dateFormated=$(date +%Y-%m-%d_%H-%M-%S)
      export CLINIC_ARGS="--dest ${PROFILING_FOLDER} --name ${CLINIC_APP}-report-${dateFormated}"
      timeout --signal=SIGINT ${CLINIC_TIMEOUT_TIME} npm run dev:clinic:${CLINIC_APP}
    else
      npm run dev
    fi
  else
    npm start
  fi
else 
  echo "SIMVA API not running. Exit."
  exit 1
fi