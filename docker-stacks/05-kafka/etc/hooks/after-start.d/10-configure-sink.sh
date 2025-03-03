#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
  ${SIMVA_HOME}/bin/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration" "true" "false";
else 
  ${SIMVA_HOME}/bin/wait-available.sh "Keycloak SIMVA REALM" "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/auth/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration" "true" "false";
fi

${SIMVA_HOME}/bin/wait-available.sh "Minio" "https://${SIMVA_MINIO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/minio/health/live" "true" "false";

mc_max_retries=${SIMVA_MAX_RETRIES}
wait_time=${SIMVA_WAIT_TIME};
count=${mc_max_retries};
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
    echo 1>&2 "Checking kafka connect: $((${mc_max_retries}-$count+1)) pass";
    set +e
    docker compose exec connect curl -f -sS http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/
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

connector_name=$(jq '.name' "${SIMVA_CONFIG_TEMPLATE_HOME}/kafka/connect/simva-sink.json" -r)

set +e
docker compose exec connect curl -f -sS \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/connectors/${connector_name} >/dev/null 2>&1
ret=$?
echo $ret
set -e

jq_script=$(cat <<'JQ_SCRIPT'
  .config["store.url"]=$minioUrl
    | .config["aws.access.key.id"]=$minioUser
      | .config["aws.secret.access.key"]=$minioSecret
        | .config["s3.bucket.name"]=$bucketName
          | .config["topics.dir"]=$topicsDir
            | .config["topics"]=$topics
              | .config["flush.size"]=$flushSize
                | .config["rotate.schedule.interval.ms"]=$rotateInterval
                        | .
JQ_SCRIPT
)

scheduleIntervalMin="${SIMVA_TRACES_ROTATE_SCHEDULE_INTERVAL_IN_MIN}"
scheduleIntervalMs=$((scheduleIntervalMin * 60 * 1000))

cat ${SIMVA_CONFIG_HOME}/kafka/connect-template/simva-sink.json | jq \
  --arg minioUrl "https://${SIMVA_MINIO_API_HOST_SUBDOMAIN:-minio-api}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/" \
  --arg minioUser "${SIMVA_KAFKA_CONNECT_SINK_USER}" \
  --arg minioSecret "${SIMVA_KAFKA_CONNECT_SINK_SECRET}" \
  --arg bucketName "${SIMVA_TRACES_BUCKET_NAME}" \
  --arg topicsDir "${SIMVA_SINK_TOPICS_DIR}" \
  --arg topics "${SIMVA_TRACES_TOPIC}" \
  --arg flushSize "${SIMVA_TRACES_FLUSH_SIZE}" \
  --arg rotateInterval "${scheduleIntervalMs}" \
  "$jq_script" > "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json"

set +e
if [[ $ret -eq 0 ]]; then 
  connector_name=$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)
  echo "DELETE"
  docker compose exec connect curl \
      --request DELETE \
      http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/connectors/${connector_name} #>/dev/null 2>&1
    retDelete=$?
    echo $retDelete
fi 

echo "POST"
docker compose exec connect curl -f -sS \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --request POST \
  --data "$(echo $(jq -c . "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json"))" \
  http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/connectors #>/dev/null 2>&1
retPost=$?
echo $retPost
set -e