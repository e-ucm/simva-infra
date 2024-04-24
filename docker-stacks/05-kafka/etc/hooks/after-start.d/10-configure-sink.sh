#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

mc_max_retries=${SIMVA_MAX_RETRIES:-20}
wait_time=${SIMVA_WAIT_TIME:-10};
count=${mc_max_retries};
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
  echo 1>&2 "Checking Keycloak availability for kafka: $((${mc_max_retries}-$count+1)) pass";
  set +e
  wget "https://${SIMVA_SSO_HOST_SUBDOMAIN:-sso}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/realms/${SIMVA_SSO_REALM:-simva}/.well-known/openid-configuration" -O - >/dev/null;
  ret=$?;
  set -e
  if [ $ret -eq 0 ]; then
    done="ok";
  else
    echo 1>&2 "Keycloak not available, waiting ${wait_time}s";
    sleep ${wait_time};
  fi;
  count=$((count-1));
done;
if [ $count -eq 0 ] && [ "$done" != "ok" ]; then
  echo 1>&2 "Keycloak not available !";
  exit 1
fi;
if [ "$done" == "ok" ]; then
  echo 1>&2 "Keycloak available !";
fi;

count=${mc_max_retries};
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
  echo 1>&2 "Checking minio: $((${mc_max_retries}-$count+1)) pass";
  set +e
  wget "https://${SIMVA_MINIO_HOST_SUBDOMAIN:-minio}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/minio/health/live" -O - >/dev/null;
  ret=$?;
  set -e
  if [ $ret -eq 0 ]; then
    done="ok";
  else
    echo 1>&2 "Minio not available, waiting ${wait_time}s";
    sleep ${wait_time};
  fi;
  count=$((count-1));
done;
if [ $count -eq 0 ] && [ "$done" != "ok" ]; then
  echo 1>&2 "Minio not available !";
  exit 1
fi;
if [ "$done" == "ok" ]; then
  echo 1>&2 "Minio available !";
fi;

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

connector_name=$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink-template.json" -r)

set +e
###NOT WORKING --- TO FIX###
docker compose exec connect curl -f -sS \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/connectors/${connector_name} >/dev/null 2>&1
ret=$?
echo $ret
set -e

if [[ $ret -ne 0 ]]; then
  echo "JQ Script starting"
  jq_script=$(cat <<'JQ_SCRIPT'
  .config["store.url"]=$minioUrl
    | .config["aws.access.key.id"]=$minioUser
      | .config["aws.secret.access.key"]=$minioSecret
        | .config["s3.bucket.name"]=$bucketName
          | .config["topics.dir"]=$topicsDir
            | .config["topics"]=$topics
              | .config["flush.size"]=$flushSize
                | .
JQ_SCRIPT
)
  cat ${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink-template.json | jq \
  --arg minioUrl "https://${SIMVA_MINIO_HOST_SUBDOMAIN:-minio}.${SIMVA_EXTERNAL_DOMAIN:-external.test}" \
  --arg minioUser "${SIMVA_KAFKA_CONNECT_SINK_USER}" \
  --arg minioSecret "${SIMVA_KAFKA_CONNECT_SINK_SECRET}" \
  --arg bucketName "${SIMVA_TRACES_BUCKET_NAME}" \
  --arg topicsDir "${SIMVA_SINK_TOPICS_DIR}" \
  --arg topics "${SIMVA_TRACES_TOPIC}" \
  --arg flushSize "${SIMVA_TRACES_FLUSH_SIZE}" \
  "$jq_script" > "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json"

  connector_name=$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)
  
  echo "JQ Script finished"
  set +e
  ###NOT WORKING --- TO FIX###
  docker compose exec connect curl -f -sS \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --request POST \
    --data '/usr/share/simva/simva-sink.json' \ 
    http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/connectors >/dev/null 2>&1
    ret=$?
    echo $ret
  set -e
fi
