mkdir -p ${SIMVA_STORAGE_PATH:-/storage} && cd /home/node/app

#start api
echo "${NODE_ENV:-production}"
if [[ "${NODE_ENV:-production}" == "development" ]]; then
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