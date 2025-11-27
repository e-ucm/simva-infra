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
    echo >&2 "missing payload";
    exit 1;
fi
payload=${3}

if [[ $# -lt 4 ]]; then
    echo >&2 "missing token variable name";
    exit 1;
fi
token_variable_name=${4}

if [[ $# -lt 5 ]]; then
    echo >&2 "missing cacert path";
    exit 1;
fi
cacert=${5}
if [[ $cacert == "false" ]]; then
  cacert=""
else 
  cacert=" --cacert $cacert"
fi

mc_max_retries=${SIMVA_MAX_RETRIES}
wait_time=${SIMVA_WAIT_TIME};
count=${mc_max_retries};
done="ko";
while [ $count -gt 0 ] && [ "$done" != "ok" ]; do
  echo 1>&2 "Checking $stack_name availability: $((${mc_max_retries}-$count+1)) pass";
  set +e
  # Make POST request to API and get token
  token=$(curl -s $cacert -X POST -H "Content-Type: application/json" -d "$payload" "$stack_host");
  set -e
  if [[ "$token" =~ .*"$token_variable_name".* ]]; then
    echo "Got $token_variable_name:"
    echo "$token"
    done="ok";
  else
    echo "Failed to get $token_variable_name"
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