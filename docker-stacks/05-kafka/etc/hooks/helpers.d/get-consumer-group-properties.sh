#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define variables
KAFKA_CONTAINER_NAME="kafka1"
BOOTSTRAP_SERVER="localhost:9092"
CONSUMER_GROUP=""
TOPIC=""

SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$SCRIPT_DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )

function usage ()
{
    echo 1>&2 "Usage: ${SOURCE} [Options]"
    echo 1>&2 "Get properties of consumer group."
    echo 1>&2 "Options:"
    echo 1>&2 "  -h, --help"
    echo 1>&2 "      Shows this help message and exits."
    echo 1>&2 "  -c, --consumer <cache path>"
    echo 1>&2 "      Consumer name."
    echo 1>&2 "  -t, --topic <topic>"
    echo 1>&2 "      Topic name."
}

LIST_LONG_OPTIONS=(
  "help"
  "consumer:"
  "topic:"
)
LIST_SHORT_OPTIONS=(
  "h"
  "c:"
  "t:"
)

opts=$(getopt \
    --longoptions "$(printf "%s," "${LIST_LONG_OPTIONS[@]}")" \
    --options "$(printf "%s", "${LIST_SHORT_OPTIONS[@]}")" \
    --name "${SOURCE}" \
    -- "$@"
)

eval set -- $opts
echo $#
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c | --consumer )
        CONSUMER_GROUP="$2"
        shift 2
        ;;
    -t | --topic )
        TOPIC="$2"
        shift 2
        ;;
    --)
      shift
      break
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

# Get the current offset
output=$(docker compose exec -it $KAFKA_CONTAINER_NAME \
      kafka-consumer-groups \
      --bootstrap-server $BOOTSTRAP_SERVER \
      --describe --group $CONSUMER_GROUP);

# Parse the output to get the offsets for the specified topic
parsed=$(echo "$output" | grep "$TOPIC" | grep $TOPIC | tr -s ' ');
echo $parsed;