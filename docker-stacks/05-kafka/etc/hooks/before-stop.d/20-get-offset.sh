set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x
service_name="kafka1"
set +e
up=$(docker compose ps $service_name | grep $service_name)
set -e
if [[ ! $up == undefined  ]]; then
    echo "The container is running."
    CONSUMER_GROUP=connect-$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)
    TOPIC="${SIMVA_TRACES_TOPIC}"
    outputparsed=$("${STACK_HOME}/etc/hooks/helpers.d/get-consumer-group-properties.sh" -c $CONSUMER_GROUP -t $TOPIC)
    current_offset=$(echo "$outputparsed" | cut -d ' ' -f 4)
    offset=$(echo "$outputparsed" | cut -d ' ' -f 5)
    lag=$(echo "$outputparsed" | cut -d ' ' -f 6)
    echo "{ \"current_offset\" : \"$current_offset\", \"offset\" : \"$offset\", \"lag\" : \"$lag\" }" > "${SIMVA_CONFIG_HOME}/kafka/connect/kafka-offset.json"
else
    echo "The container is not running."
fi