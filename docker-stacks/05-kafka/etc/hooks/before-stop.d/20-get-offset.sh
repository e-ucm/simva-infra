set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

outputparsed=$("${STACK_HOME}/etc/hooks/helpers.d/get-consumer-group-properties.sh")
current_offset=$(echo "$outputparsed" | cut -d ' ' -f 4)
offset=$(echo "$outputparsed" | cut -d ' ' -f 5)
lag=$(echo "$outputparsed" | cut -d ' ' -f 6)
echo "{ \"current_offset\" : \"$current_offset\", \"offset\" : \"$offset\", \"lag\" : \"$lag\" }" > "${SIMVA_CONFIG_HOME}/kafka/connect/kafka-offset.json"