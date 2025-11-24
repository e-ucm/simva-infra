#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
  ${SIMVA_HOME}/bin/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";
else 
  ${SIMVA_HOME}/bin/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/auth/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";
fi

${SIMVA_HOME}/bin/wait-available.sh "Minio" "https://${SIMVA_MINIO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/minio/health/live" "true" "$SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE";

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="connect"

mc_max_retries=${SIMVA_MAX_RETRIES}
wait_time=${SIMVA_WAIT_TIME};
count=${mc_max_retries};
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
    echo 1>&2 "Checking kafka connect: $((${mc_max_retries}-$count+1)) pass";
    set +e
    "${SIMVA_HOME}/bin/run-command.sh" curl -f -sS http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/
    ret=$?;
    set -e
    if [ $ret -eq 0 ]; then
    done="ok";
    else
    echo 1>&2 "Kafka connect not available, waiting ${wait_time}s";
    sleep ${wait_time};
    fi;
    count=$((count-1));
done;
if [ $count -eq 0 ] && [ "$done" != "ok" ]; then
  echo 1>&2 "Kafka Connect not available !";
  exit 1
fi;
if [ "$done" == "ok" ]; then
  echo 1>&2 "Kafka Connect available !";
fi;