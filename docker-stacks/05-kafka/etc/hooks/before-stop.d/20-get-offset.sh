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
    CONSUMER_GROUP=connect-$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)
    TOPIC="${SIMVA_TRACES_TOPIC}"
    outputparsed=$("${HELPERS_STACK_HOME}/get-consumer-group-properties.sh" -c $CONSUMER_GROUP -t $TOPIC)
    current_offset=$(echo "$outputparsed" | cut -d ' ' -f 4)
    offset=$(echo "$outputparsed" | cut -d ' ' -f 5)
    lag=$(echo "$outputparsed" | cut -d ' ' -f 6)
    echo "{ \"current_offset\" : \"$current_offset\", \"offset\" : \"$offset\", \"lag\" : \"$lag\" }" > "${SIMVA_CONFIG_HOME}/kafka/connect/kafka-offset.json"
else
    echo "The container is not running."
fi