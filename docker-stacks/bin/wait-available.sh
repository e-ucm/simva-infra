#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

echo "Wait available : $@"
if [[ $# -lt 1 ]]; then
    echo >&2 "missing name";
    exit 1;
fi
stack_name=${1}

if [[ $# -lt 2 ]]; then
    echo >&2 "missing host";
    exit 1;
fi
stack_host=${2}

if [[ $# -lt 3 ]]; then
    echo >&2 "missing check redirect";
    exit 1;
fi
check_redirect=${3}

if [[ $# -lt 4 ]]; then
    echo >&2 "missing cacert path";
    exit 1;
fi
cacert=${4}
if [[ $cacert == "false" ]]; then
  cacert=""
else 
  cacert=" --cacert $cacert"
fi


payload=${5:-}

mc_max_retries=${SIMVA_MAX_RETRIES}
wait_time=${SIMVA_WAIT_TIME};
count=${mc_max_retries};
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
  echo 1>&2 "Checking $stack_name availability: $((${mc_max_retries}-$count+1)) pass";
  set +e
  if [[ $check_redirect == "true" ]]; then 
    if [[ -n $payload ]]; then 
      STATUS_RECEIVED=$(curl -s $cacert -u $payload -L --write-out "%{http_code}\n" "$stack_host" --output /dev/null --silent);
    else 
      STATUS_RECEIVED=$(curl -s $cacert -IL --write-out "%{http_code}\n" "$stack_host" --output /dev/null --silent);
    fi;
  else
    if [[ -n $payload ]]; then 
      STATUS_RECEIVED=$(curl -s $cacert -u $payload --write-out "%{http_code}\n" "$stack_host" --output /dev/null --silent);
    else 
      STATUS_RECEIVED=$(curl -s $cacert --write-out "%{http_code}\n" "$stack_host" --output /dev/null --silent);
    fi;
  fi
  set -e
  if [[ ${STATUS_RECEIVED:0:1} == "2" ]]; then
    done="ok";
  else
    echo 1>&2 "$stack_name not available, waiting ${wait_time}s";
    sleep ${wait_time};
  fi;
  count=$((count-1));
done;
if [ $count -eq 0 ] && [ "$done" != "ok" ]; then
  echo 1>&2 "$stack_name not available !";
  exit 1
fi;
if [ "$done" == "ok" ]; then
  echo 1>&2 "$stack_name available !";
fi;