#!/usr/bin/env bash
set -euo pipefail
if [[ "${SIMVA_RUSTFS_ENABLE:-false}" == "true" ]]; then
    dockerimage="${SIMVA_RUSTFS_RC_IMAGE}"
    dockerversion="${SIMVA_RUSTFS_RC_VERSION}"
    containercommand="rc"
    url="http://${SIMVA_RUSTFS_HOST_SUBDOMAIN:-rustfs}.${SIMVA_INTERNAL_DOMAIN:-internal.test}:9000"
    accesskey="${SIMVA_RUSTFS_ACCESS_KEY}"
    secretkey="${SIMVA_RUSTFS_SECRET_KEY}"
    name="rustfs"
    addhostcommand="alias set"
    userlistcommand="admin user ls"
    policylistcommand="admin policy ls"
    camount=""
    caenv=""
else 
    containercommand="mc"
    dockerimage="${SIMVA_MINIO_MC_IMAGE}"
    dockerversion="${SIMVA_MINIO_MC_VERSION}"
    url="http://${SIMVA_MINIO_HOST_SUBDOMAIN:-minio}.${SIMVA_INTERNAL_DOMAIN:-internal.test}:9000"
    accesskey="${SIMVA_MINIO_ACCESS_KEY}"
    secretkey="${SIMVA_MINIO_SECRET_KEY}"
    name="minio"
    addhostcommand="config host add"
    userlistcommand="admin user list"
    policylistcommand="admin policy list"
    camount="-v ${SIMVA_TLS_HOME}/ca:/root/.mc/certs/CAs/"
    caenv=""
fi

[[ "${DEBUG:-false}" == "true" ]] && set -x
export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="kafka1"

if [ ! -e "${SIMVA_DATA_HOME}/kafka/.minio-events-topics-created" ]; then
  set +e
  "${SIMVA_BIN_HOME}/run-command.sh" kafka-topics --create --topic "minio-events" --partitions 1 --replication-factor 1 --bootstrap-server http://kafka1.${SIMVA_INTERNAL_DOMAIN}:19092
  retPost=$?
  echo $retPost
  set -e;
  if [[ $retPost -eq 0 ]]; then
    touch "${SIMVA_DATA_HOME}/kafka/.minio-events-topics-created"
  fi
fi

export RUN_IN_CONTAINER_NAME="minio-client"
if [[ "${SIMVA_RUSTFS_ENABLE:-false}" == "true" ]]; then
code="$(cat <<EOF
${containercommand} ${addhostcommand} simva-minio ${url} ${accesskey} ${secretkey} &&
${containercommand} ready simva-minio &&
adminInfo=\$(${containercommand} bucket event list --json simva-minio/${SIMVA_TRACES_BUCKET_NAME} 2>/dev/null || echo '{"notifications":[]}') &&
hasNotifications=false
if echo "\$adminInfo" | jq -e '.notifications | length > 0' >/dev/null 2>&1; then
    hasNotifications=true
fi
if [[ "\$hasNotifications" == "true" ]]; then
    echo "Kafka event already exists in ${name}. Checking for conflicts..."
    echo \$adminInfo
    # rustfs bucket event list returns object with notifications array
    fileUploadArn=\$(echo \$adminInfo | jq -r '.notifications[] | select(.arn | test("minio-file-upload")) | .arn' 2>/dev/null || echo "")
    echo \$fileUploadArn
    if [[ -n \$fileUploadArn && \$fileUploadArn != "null" ]]; then
        echo "Found. Removing existing notification config..."
        ${containercommand} bucket event remove simva-minio/${SIMVA_TRACES_BUCKET_NAME} \$fileUploadArn
        export RUN_IN_FLAG_UI=true
        ${containercommand} --debug admin service restart simva-minio/
        export RUN_IN_FLAG_UI=false
        ${containercommand} ready simva-minio
    else 
        echo "Creating event listener"
        ${containercommand} --debug admin config set simva-minio notify_kafka:minio-file-upload brokers=kafka1.${SIMVA_INTERNAL_DOMAIN}:19092 topic=${SIMVA_MINIO_EVENTS_TOPIC}
        echo "Event listener created"
        export RUN_IN_FLAG_UI=true
        ${containercommand} --debug admin service restart simva-minio/
        export RUN_IN_FLAG_UI=false
        ${containercommand} ready simva-minio
    fi
    # Get the ARN from the kafka notification we just created
    info=\$(${containercommand} bucket event list --json simva-minio/${SIMVA_TRACES_BUCKET_NAME} 2>/dev/null || echo '{"notifications":[]}')
    arn=\$(echo \$info | jq -r '.notifications[] | select(.arn | test("minio-file-upload")) | .arn' 2>/dev/null || echo "")
    echo \$arn
    if [[ -n \$arn && \$arn != "null" ]]; then
        # rustfs bucket event add doesn't support prefix/suffix, they must be configured differently
        ${containercommand} --debug bucket event add simva-minio/${SIMVA_TRACES_BUCKET_NAME} \$arn --event put
    else
        echo "No ARN found for minio-file-upload notification"
        exit 1
    fi
else
    echo "No existing notifications found. Creating event listener"
    ${containercommand} --debug admin config set simva-minio notify_kafka:minio-file-upload brokers=kafka1.${SIMVA_INTERNAL_DOMAIN}:19092 topic=${SIMVA_MINIO_EVENTS_TOPIC}
    echo "Event listener created"
    export RUN_IN_FLAG_UI=true
    ${containercommand} --debug admin service restart simva-minio/
    export RUN_IN_FLAG_UI=false
    ${containercommand} ready simva-minio
    # Get the ARN from the kafka notification we just created
    info=\$(${containercommand} bucket event list --json simva-minio/${SIMVA_TRACES_BUCKET_NAME} 2>/dev/null || echo '{"notifications":[]}')
    arn=\$(echo \$info | jq -r '.notifications[] | select(.arn | test("minio-file-upload")) | .arn' 2>/dev/null || echo "")
    echo \$arn
    if [[ -n \$arn && \$arn != "null" ]]; then
        ${containercommand} --debug bucket event add simva-minio/${SIMVA_TRACES_BUCKET_NAME} \$arn --event put
    else
        echo "No ARN found for minio-file-upload notification"
        exit 1
    fi
fi
EOF
)"
else
code="$(cat <<EOF
${containercommand} ${addhostcommand} simva-minio ${url} ${accesskey} ${secretkey} &&
${containercommand} ready simva-minio &&
adminInfo=\$(${containercommand} admin info --json simva-minio/${SIMVA_TRACES_BUCKET_NAME}) &&
if [[ -n "\$adminInfo" ]]; then
    echo "Kafka event already exists in ${name}. Checking for conflicts..."
    info=\$(echo \$adminInfo | jq ".info")
    echo \$info
    arn=\$(echo \$info | jq -r ".sqsARN // []")
    arnTable=\$(echo "\$arn" | jq -c -r '. | join(" ")')
    echo \$arnTable
    fileUploadArn=\$(echo "\$arn" | jq '.[] | select(test("minio-file-upload"))')
    echo \$fileUploadArn
    if [[ -n \$fileUploadArn ]]; then
        echo "Found. Removing existing notification config..."
        ${containercommand} event rm --force simva-minio/${SIMVA_TRACES_BUCKET_NAME}
        export RUN_IN_FLAG_UI=true
        ${containercommand} --debug admin service restart simva-minio/
        export RUN_IN_FLAG_UI=false
        ${containercommand} ready simva-minio
    else 
        echo "Creating event listener"
        ${containercommand} --debug admin config set simva-minio notify_kafka:minio-file-upload brokers="kafka1.${SIMVA_INTERNAL_DOMAIN}:19092" topic="${SIMVA_MINIO_EVENTS_TOPIC}"
        echo "Event listener created"
        export RUN_IN_FLAG_UI=true
        ${containercommand} --debug admin service restart simva-minio/
        export RUN_IN_FLAG_UI=false
        ${containercommand} ready simva-minio
    fi
    info=\$(${containercommand} admin info --json simva-minio/)
    arn=\$(echo \$info | jq .info.sqsARN[0])
    echo \$arn
    ${containercommand} --debug event add --event put --prefix "${SIMVA_SINK_TOPICS_DIR}/${SIMVA_TRACES_TOPIC}/_id=" --suffix "${SIMVA_TRACES_TOPIC}+*.json" simva-minio/${SIMVA_TRACES_BUCKET_NAME} \$arn
else
    echo "Kafka info not found."
    exit 1
fi
EOF
)"
fi
docker_args=(--rm --network traefik_services)
[[ -n "${camount}" ]] && docker_args+=(${camount})
[[ -n "${caenv}" ]] && docker_args+=(${caenv})
docker_args+=(--entrypoint /bin/sh "${dockerimage}:${dockerversion}" -c "$code")
docker run --rm "${docker_args[@]}"