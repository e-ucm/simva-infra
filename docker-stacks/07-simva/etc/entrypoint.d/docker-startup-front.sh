#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

admin_username=$(echo ${SIMVA_USER} | tr '[:upper:]' '[:lower:]');
json="{\"username\":\"${admin_username}\",\"password\":\"${SIMVA_PASSWORD}\"}";

set +e
/bin/wait-available-with-connection.sh 'SIMVA API' "${SIMVA_API_PROTOCOL}://${SIMVA_API_HOST}:${SIMVA_API_PORT}/users/login" ${json} 'token' ${NODE_EXTRA_CA_CERTS};
ret=$?
set -e
echo $ret

if [[ $ret == 0 ]]; then
  cd /home/node/app

  #start front
  echo "${NODE_ENV}"
  if [[ "${NODE_ENV}" == "development" ]]; then
    if [[ "${ENABLE_DEBUG_PROFILING:-false}" == "true" ]]; then
        if [[ ! -e ${PROFILING_FOLDER} ]]; then 
          mkdir -p ${PROFILING_FOLDER}
          chmod -R ${SIMVA_NODE_DIR_MODE} ${PROFILING_FOLDER}
        fi
        rm -rf ./node_trace.*.log
        dateFormated=$(date +%Y-%m-%d_%H-%M-%S)
        export CLINIC_ARGS="--dest ${PROFILING_FOLDER} --name ${CLINIC_APP}-report-${dateFormated}"
        timeout --signal=SIGINT ${CLINIC_TIMEOUT_TIME} npm run dev:clinic:${CLINIC_APP}
    else
      npm run dev
    fi
  else
    npm start
  fi
else 
  echo "SIMVA API not running. Exit."
  exit 1
fi
