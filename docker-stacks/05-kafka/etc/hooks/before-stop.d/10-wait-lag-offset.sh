#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

canStop=false;

while [[ $canStop == false ]]; do
  echo "Working... Please wait ${SIMVA_TRACES_ROTATE_SCHEDULE_INTERVAL_IN_MIN} minutes to consume message via rotate schedule. Press Ctrl+C to stop checking..."
  outputparsed=$("${STACK_HOME}/etc/hooks/helpers.d/get-consumer-group-properties.sh")
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
