#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

RUN_IN_CONTAINER=true
RUN_IN_CONTAINER_NAME="kafka1"
set +e
source "${SIMVA_BIN_HOME}/check-docker-running.sh"
_check_docker_running
ret=$?
set -e
echo $ret
if [[ $ret == 0 ]]; then
  echo "The container is running."
  echo "Working... Please wait ${SIMVA_TRACES_ROTATE_SCHEDULE_INTERVAL_IN_MIN} minutes to consume message via rotate schedule. Press Ctrl+C to stop checking..."
  CONSUMER_GROUP=connect-$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)
  TOPIC="${SIMVA_TRACES_TOPIC}"
  "${HELPERS_STACK_HOME}/wait-lag-offset.sh" -c $CONSUMER_GROUP -t $TOPIC
  "${HELPERS_STACK_HOME}/wait-lag-offset.sh" -c "${SIMVA_TRACE_ALLOCATOR_KAFKA_GROUP_ID}" -t "${SIMVA_MINIO_EVENTS_TOPIC}"
else
    echo "The container is not running."
fi