#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

mc_max_retries=${SIMVA_MAX_RETRIES:-20}
wait_time=${SIMVA_WAIT_TIME:-10};
count=${mc_max_retries};
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
  res="{}"
  msg=""
  echo 1>&2 "Checking Simva API availability: $((${mc_max_retries}-$count+1)) pass";
  set +e
  res=$(curl -s -X POST -H "Content-Type: application/json" "https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN:-simva-api}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/");
  msg=$(echo $res | jq ".message")
  set -e
  if [[ $msg = "\"Not found\"" ]]; then
    done="ok";
  else
    echo 1>&2 "Simva API not available, waiting ${wait_time}s";
    sleep ${wait_time};
  fi;
  count=$((count-1));
done;
if [ $count -eq 0 ] && [ "$done" != "ok" ]; then
  echo 1>&2 "Simva API not available !";
  exit 1
fi;
if [ "$done" == "ok" ]; then
  echo 1>&2 "Simva API available !";
fi;
