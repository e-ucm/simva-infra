#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define variables
KAFKA_CONTAINER_NAME="kafka1"
BOOTSTRAP_SERVER="localhost:9092"
CONSUMER_GROUP=connect-$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)
TOPIC="${SIMVA_TRACES_TOPIC}"
outputfile="${SIMVA_CONFIG_HOME}/kafka/connect/kafka-offset.json"

# Check if the file exists
if [[ ! -f "$outputfile" ]]; then
    echo "File $outputfile does not exist."
    exit 1
fi

# Use jq to extract the value of 'offset'
offset=$(jq -r '.offset' "$outputfile")

# Print the extracted value
echo "The end offset is: $offset"

outputparsed=$("${STACK_HOME}/etc/hooks/helpers.d/get-consumer-group-properties.sh")
actualOffset=$(echo "$outputparsed" | cut -d ' ' -f 5)
NUM_MESSAGES=$(($offset-$actualOffset));

# Send the specified number of empty messages
for ((i=0; i<NUM_MESSAGES; i++)); do
    docker compose exec -it $KAFKA_CONTAINER_NAME kafka-console-producer "--bootstrap-server $BOOTSTRAP_SERVER --topic $TOPIC"
done

echo "Sent $NUM_MESSAGES empty messages to topic $TOPIC"

# Get the current offset
docker compose exec -it $KAFKA_CONTAINER_NAME \
            kafka-consumer-groups \
            --bootstrap-server $BOOTSTRAP_SERVER \
            --reset-offsets --group $CONSUMER_GROUP \
            --to-offset $offset \
            --topic $TOPIC:0 \
            --execute;