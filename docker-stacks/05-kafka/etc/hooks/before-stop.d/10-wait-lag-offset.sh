#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

service_name="kafka1"
set +e
up=$(docker compose ps $service_name | grep $service_name)
echo $up
set -e
if [[ ! $up == undefined  ]]; then
  echo "The container is running."
  echo "Working... Please wait ${SIMVA_TRACES_ROTATE_SCHEDULE_INTERVAL_IN_MIN} minutes to consume message via rotate schedule. Press Ctrl+C to stop checking..."
  CONSUMER_GROUP=connect-$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)
  TOPIC="${SIMVA_TRACES_TOPIC}"
  "${STACK_HOME}/etc/hooks/helpers.d/wait-lag-offset.sh" -c $CONSUMER_GROUP -t $TOPIC
  "${STACK_HOME}/etc/hooks/helpers.d/wait-lag-offset.sh" -c "${SIMVA_TRACE_ALLOCATOR_KAFKA_GROUP_ID}" -t "${SIMVA_MINIO_EVENTS_TOPIC}"
else
    echo "The container is not running."
fi