#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

wait_time=10;
count=20;
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
  echo 1>&2 "Checking Keycloak availability for kafka: $((20-$count+1)) pass";
  set +e
  wget "${SIMVA_SSO_OPENID_CONFIG_URL}" -O - >/dev/null;
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
if [ $count -eq 0 ]; then
  echo 1>&2 "Keycloak not available !";
  exit 1
fi;

count=20;
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
  echo 1>&2 "Checking minio: $((20-$count+1)) pass";
  set +e
  wget "${SIMVA_KAFKA_CONNECT_SINK_MINIO_URL}/minio/health/live" -O - >/dev/null;
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
if [ $count -eq 0 ]; then
  echo 1>&2 "Minio not available !";
  exit 1
fi;

count=20;
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
    echo 1>&2 "Checking kafka connect: $((20-$count+1)) pass";
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
if [ $count -eq 0 ]; then
    echo 1>&2 "Kafka connect not available !";
    exit 1
fi;

connector_name=$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink-template.json" -r)

set +e
stack exec connect curl -f -sS \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/connectors/${connector_name} >/dev/null 2>&1
ret=$?
set -e

if [[ $ret -ne 0 ]]; then

  jq_script=$(cat <<'JQ_SCRIPT'
  .config["store.url"]=$minioUrl
    | .config["aws.access.key.id"]=$minioUser
      | .config["aws.secret.access.key"]=$minioSecret
        | .config["s3.bucket.name"]=$bucketName
          | .config["topics.dir"]=$topicsDir
            | .config["topics"]=$topics
              | .
JQ_SCRIPT
)
  cat ${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink-template.json | jq \
  --arg minioUrl "${SIMVA_KAFKA_CONNECT_SINK_MINIO_URL}" \
  --arg minioUser "${SIMVA_KAFKA_CONNECT_SINK_USER}" \
  --arg minioSecret "${SIMVA_KAFKA_CONNECT_SINK_SECRET}" \
  --arg bucketName "${SIMVA_TRACES_BUCKET_NAME}" \
  --arg topicsDir "${SIMVA_SINK_TOPICS_DIR}" \
  --arg topics "${SIMVA_TRACES_TOPIC}" \
  "$jq_script" > "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json"

  connector_name=$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)

  docker compose exec connect curl -f -sS \
    --header 'Content-Type: application/json' \
    --header 'Accept: application/json' \
    --request POST \
    --data '@/usr/share/simva/simva-sink.json' \
    http://connect.${SIMVA_INTERNAL_DOMAIN}:8083/connectors >/dev/null 2>&1
fi
