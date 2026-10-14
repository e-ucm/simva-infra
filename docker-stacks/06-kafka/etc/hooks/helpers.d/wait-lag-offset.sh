#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# Define variables
KAFKA_CONTAINER_NAME="kafka1"
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

canStop=false;
while [[ $canStop == false ]]; do
  
  outputparsed=$("${HELPERS_STACK_HOME}/get-consumer-group-properties.sh" -c $CONSUMER_GROUP -t $TOPIC)
  echo $outputparsed
  if [[ -e "$outputparsed" ]]; then
    current_offset=$(echo "$outputparsed" | cut -d ' ' -f 4)
    log_end_offset=$(echo "$outputparsed" | cut -d ' ' -f 5)
    lag=$(echo "$outputparsed" | cut -d ' ' -f 6)
    echo "current_offset : " $current_offset
    echo "log_end_offset : " $log_end_offset
    echo "Lag : " $lag
    
    if [[ $lag == 0 ]]; then 
      canStop=true;
    else 
      if [[ $lag == "-" ]]; then 
        canStop=true;
      else 
        echo "Waiting " $(( ${SIMVA_TRACES_ROTATE_SCHEDULE_INTERVAL_IN_MIN} / 3)) "minutes";
        sleep $((60 * $SIMVA_TRACES_ROTATE_SCHEDULE_INTERVAL_IN_MIN / 3));
      fi
    fi
  else 
    canStop=true;
  fi
done
echo "Loop has stopped";