#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

canStop=false;

while [[ $canStop == false ]]; do 
  echo "Working... Press Ctrl+C to stop"
  outputparsed=$("${STACK_HOME}/etc/hooks/helpers.d/get-consumer-group-properties.sh")
  #echo $outputparsed
  current_offset=$(echo "$outputparsed" | cut -d ' ' -f 4)
  log_end_offset=$(echo "$outputparsed" | cut -d ' ' -f 5)
  lag=$(echo "$outputparsed" | cut -d ' ' -f 6)
  echo "current_offset : " $current_offset 
  echo "log_end_offset : " $log_end_offset 
  echo "Lag : " $lag
  sleep 5
  if [[ $lag == 0 ]]; then 
    canStop=true;
  fi
  if [[ $lag == "-" ]]; then 
    canStop=true;
  fi
done

echo "Loop has stopped";
