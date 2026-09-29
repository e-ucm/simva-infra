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
# RustFS exposes the kafka target as a single built-in instance named after the
# scope, so its ARN carries no instance id and no region.
kafkaTargetArn="arn:minio:sqs::notify_kafka"
# The stock queue_dir (/opt/rustfs/events) does not exist in the container, and
# the target silently fails to initialise when it cannot be created.
kafkaQueueDir="${SIMVA_RUSTFS_NOTIFY_QUEUE_DIR:-/data/rustfs/events}"
code="$(cat <<EOF
# This snippet runs under /bin/sh (busybox in rustfs/rc), so it must stay POSIX:
# no [[ ... ]], and never more than one test per command.
retry() {
    tries=0
    while [ \$tries -lt 5 ]; do
        if "\$@"; then
            return 0
        fi
        tries=\$((tries + 1))
        sleep 3
    done
    echo "Command failed after \$tries attempts: \$*"
    return 1
}

# rc ready answers against the old listener while the service is still shutting
# down, so poll for a while instead of trusting a single check.
wait_for_${name}() {
    tries=0
    while [ \$tries -lt 20 ]; do
        if ${containercommand} ready simva-minio >/dev/null 2>&1; then
            return 0
        fi
        tries=\$((tries + 1))
        sleep 2
    done
    echo "Timed out waiting for ${name} to accept connections"
    return 1
}

# "rc ready <alias>" needs the alias to exist first, and the alias needs the
# server to be up, so register it with retries and only then poll for readiness.
retry ${containercommand} ${addhostcommand} simva-minio ${url} ${accesskey} ${secretkey} || exit 1
wait_for_${name} || exit 1

# RustFS only accepts the bare scope name here. The named "notify_kafka:<id>"
# form that MinIO accepts is rejected with "Configuration error".
# The queue dir has to be checked too: leaving it at the /opt/rustfs/events
# default makes the target fail to initialise and silently drop every event.
notifyConfig=\$(${containercommand} admin config get simva-minio notify_kafka 2>/dev/null)
if ! echo "\$notifyConfig" | grep -q 'brokers="kafka1.${SIMVA_INTERNAL_DOMAIN}:19092"' ||
   ! echo "\$notifyConfig" | grep -q 'queue_dir="${kafkaQueueDir}"'; then
    echo "Configuring the kafka notification target on ${name}..."
    echo "\$notifyConfig"
    ${containercommand} admin config set simva-minio notify_kafka \\
        enable=on \\
        brokers=kafka1.${SIMVA_INTERNAL_DOMAIN}:19092 \\
        topic=${SIMVA_MINIO_EVENTS_TOPIC} \\
        queue_dir=${kafkaQueueDir} || exit 1
    ${containercommand} admin service restart simva-minio/ >/dev/null
    wait_for_${name} || exit 1
fi

# rc cannot update a rule in place and PutBucketNotificationConfiguration
# replaces the whole rule set, so drop any stale kafka rule before re-adding it.
# Skipping this left the bucket with no rule at all on the previous run.
listRules() {
    ${containercommand} bucket event list --json simva-minio/${SIMVA_TRACES_BUCKET_NAME} 2>/dev/null
}
retry listRules > /tmp/simva-event-rules.json || exit 1
staleArn=\$(jq -r '.notifications[]? | select(.arn | test("kafka")) | .arn' < /tmp/simva-event-rules.json 2>/dev/null)
if [ -n "\$staleArn" ]; then
    echo "Removing existing notification rule: \$staleArn"
    retry ${containercommand} bucket event remove simva-minio/${SIMVA_TRACES_BUCKET_NAME} "\$staleArn" >/dev/null || exit 1
fi

# rc bucket event add has no --prefix/--suffix, so the rule matches every
# object in the bucket.
echo "Adding object-created notification for ${kafkaTargetArn}"
retry ${containercommand} bucket event add simva-minio/${SIMVA_TRACES_BUCKET_NAME} ${kafkaTargetArn} --event put || exit 1

# rc reports success even when the server rejects the rule, so verify it stuck.
retry listRules > /tmp/simva-event-rules.json || exit 1
arn=\$(jq -r '.notifications[]? | select(.arn | test("kafka")) | .arn' < /tmp/simva-event-rules.json 2>/dev/null)
if [ -z "\$arn" ]; then
    echo "No kafka notification rule is registered on ${name}/${SIMVA_TRACES_BUCKET_NAME}"
    cat /tmp/simva-event-rules.json
    exit 1
fi
echo "Kafka event notification ready on \$arn"
EOF
)"
else
code="$(cat <<EOF
${containercommand} ${addhostcommand} simva-minio ${url} ${accesskey} ${secretkey} &&
${containercommand} ready simva-minio &&
adminInfo=\$(${containercommand} admin info --json simva-minio/${SIMVA_TRACES_BUCKET_NAME}) &&
if [ -n "\$adminInfo" ]; then
    echo "Kafka event already exists in ${name}. Checking for conflicts..."
    info=\$(echo \$adminInfo | jq ".info")
    echo \$info
    arn=\$(echo \$info | jq -r ".sqsARN // []")
    arnTable=\$(echo "\$arn" | jq -c -r '. | join(" ")')
    echo \$arnTable
    fileUploadArn=\$(echo "\$arn" | jq '.[] | select(test("minio-file-upload"))')
    echo \$fileUploadArn
    if [ -n "\$fileUploadArn" ]; then
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