#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

mc_max_retries=${SIMVA_MAX_RETRIES:-20}
wait_time=${SIMVA_WAIT_TIME:-10};
count=${mc_max_retries};
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
  echo 1>&2 "Checking Jupyter availability: $((${mc_max_retries}-$count+1)) pass";
  set +e
  res=$(curl "https://${SIMVA_JUPYTER_HOST_SUBDOMAIN:-jupyter}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/");
  set -e
  if [[ $res == "404 page not found" ]]; then
    echo 1>&2 "Jupyter not available, waiting ${wait_time}s";
    sleep ${wait_time};
  else
    done="ok";
  fi;
  count=$((count-1));
done;
if [ $count -eq 0 ] && [ "$done" != "ok" ]; then
  echo 1>&2 "Jupyter not available !";
  exit 1
fi;
if [ "$done" == "ok" ]; then
  echo 1>&2 "Jupyter available !";
fi;
