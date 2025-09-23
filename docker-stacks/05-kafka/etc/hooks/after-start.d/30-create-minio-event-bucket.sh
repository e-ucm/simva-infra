#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="kafka1"

if [ ! -e "${SIMVA_DATA_HOME}/kafka/.minio-events-topics-created" ]; then
  set +e
  "${SIMVA_HOME}/bin/run-command.sh" kafka-topics --create --topic "minio-events" --partitions 1 --replication-factor 1 --bootstrap-server http://kafka1.${SIMVA_INTERNAL_DOMAIN}:19092
  retPost=$?
  echo $retPost
  set -e;
  if [[ $retPost -eq 0 ]]; then
    touch "${SIMVA_DATA_HOME}/kafka/.minio-events-topics-created"
  fi
fi

export RUN_IN_CONTAINER_NAME="minio-client"
"${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc config host add simva-minio "https://${SIMVA_MINIO_HOST_SUBDOMAIN}-api.${SIMVA_EXTERNAL_DOMAIN}" ${SIMVA_MINIO_ACCESS_KEY} ${SIMVA_MINIO_SECRET_KEY} --api s3v4"
set +e
"${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc ready simva-minio"
res=$?
echo $res
set -e
if [[ $res -ne 0 ]]; then
  echo 'Error: Unable to initialize connection to MinIO.'
  exit 1;
fi

# Step 1: Check if the event already exists in Minio
adminInfo=$("${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc admin info --json simva-minio/$SIMVA_TRACES_BUCKET_NAME")

if [[ -n "$adminInfo" ]]; then
    echo "Kafka event already exists in Minio. Checking for conflicts..."
    info=$(echo $adminInfo | jq ".info")
    echo $info
    arn=$(echo $info | jq -r ".sqsARN // []")
    arnTable=$(echo "$arn" | jq -c -r '. | join(" ")')
    echo $arnTable
    fileUploadArn=$(echo "$arn" | jq '.[] | select(test("minio-file-upload"))')
    echo $fileUploadArn
    if [[ -n $fileUploadArn ]]; then
        echo "Found. Removing existing notification config..."
        "${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc event rm --force simva-minio/${SIMVA_TRACES_BUCKET_NAME}"
        "${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc --debug admin service restart simva-minio/"
        "${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc ready simva-minio"
    else 
        echo "Creating event listener"
        "${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc --debug admin config set simva-minio/ notify_kafka:minio-file-upload brokers=\"kafka1.${SIMVA_INTERNAL_DOMAIN}:19092\" topic=\"${SIMVA_MINIO_EVENTS_TOPIC}\";"
        echo "Event listener created"
        "${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc --debug admin service restart simva-minio/"
        "${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc ready simva-minio"
    fi
    info=$("${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc admin info --json simva-minio/");
    arn=$(echo $info | jq .info.sqsARN[0])
    echo $arn
    "${SIMVA_HOME}/bin/run-command.sh" /bin/sh -c "/usr/bin/mc --debug event add --event put --prefix \"${SIMVA_SINK_TOPICS_DIR}/${SIMVA_TRACES_TOPIC}/_id=\" --suffix \"${SIMVA_TRACES_TOPIC}+*.json\" simva-minio/${SIMVA_TRACES_BUCKET_NAME} $arn"
else
    echo "Kafka info not found."
    exit 1;
fi