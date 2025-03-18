#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [ ! -e "${SIMVA_DATA_HOME}/kafka/minio-events-topics-created" ]; then
  set +e
  docker compose exec kafka1 kafka-topics --create --topic "minio-events" --partitions 1 --replication-factor 1 --bootstrap-server http://kafka1.${SIMVA_INTERNAL_DOMAIN}:19092
  retPost=$?
  echo $retPost
  set -e;
  if [[ $retPost -eq 0 ]]; then
    touch "${SIMVA_DATA_HOME}/kafka/minio-events-topics-created"
  fi
fi

docker compose exec minio-client  /bin/sh -c "/usr/bin/mc config host add simva-minio "https://${SIMVA_MINIO_HOST_SUBDOMAIN}-api.${SIMVA_EXTERNAL_DOMAIN}" ${SIMVA_MINIO_ACCESS_KEY} ${SIMVA_MINIO_SECRET_KEY} --api s3v4;
      /usr/bin/mc ready simva-minio;
      if [[ $? -ne 0 ]]; then
        echo 'Error: Unable to initialize connection to MinIO.'
        exit 1
      fi;"
if [ ! -e "${SIMVA_DATA_HOME}/minio/minio-events-initialized" ]; then
        echo "Creating event listener"
        docker compose exec minio-client /bin/sh -c "/usr/bin/mc --debug admin config set simva-minio/ notify_kafka:minio-file-upload brokers=\"kafka1.${SIMVA_INTERNAL_DOMAIN}:19092\" topic=\"${SIMVA_MINIO_EVENTS_TOPIC}\";"
        echo "Event listener created"
        docker compose exec minio-client /bin/sh -c "/usr/bin/mc --debug admin service restart simva-minio/;
        /usr/bin/mc ready simva-minio;"
        info=$(docker compose exec minio-client /bin/sh -c "/usr/bin/mc admin info --json simva-minio/");
        arn=$(echo $info | jq .info.sqsARN[0])
        echo $info
        echo $arn
        docker compose exec minio-client /bin/sh -c "/usr/bin/mc --debug event add --event put --prefix \"${SIMVA_SINK_TOPICS_DIR}/${SIMVA_TRACES_TOPIC}/_id=\" --suffix \"${SIMVA_TRACES_TOPIC}+*.json\" simva-minio/${SIMVA_TRACES_BUCKET_NAME} $arn"
        touch "${SIMVA_DATA_HOME}/minio/minio-events-initialized"
fi