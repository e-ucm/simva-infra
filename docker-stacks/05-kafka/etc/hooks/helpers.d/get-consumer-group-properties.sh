#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define variables
KAFKA_CONTAINER_NAME="kafka1"
BOOTSTRAP_SERVER="localhost:9092"
CONSUMER_GROUP=connect-$(jq '.name' "${SIMVA_CONFIG_HOME}/kafka/connect/simva-sink.json" -r)
TOPIC="${SIMVA_TRACES_TOPIC}"

# Get the current offset
output=$(docker compose exec -it $KAFKA_CONTAINER_NAME \
      kafka-consumer-groups \
      --bootstrap-server $BOOTSTRAP_SERVER \
      --describe --group $CONSUMER_GROUP);

# Parse the output to get the offsets for the specified topic
parsed=$(echo "$output" | grep "$TOPIC" | grep $TOPIC | tr -s ' ');
echo $parsed;