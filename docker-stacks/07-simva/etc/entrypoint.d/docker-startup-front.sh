cd /home/node/app

#start front
echo "${NODE_ENV:-production}"
if [[ "${NODE_ENV:-production}" == "development" ]]; then
  if [[ "${ENABLE_DEBUG_PROFILING:-false}" == "true" ]]; then
    CLINIC_ARGS="--dest ${PROFILING_FOLDER} --name ${CLINIC_APP}-report-$(date +%s)" timeout --signal=SIGINT ${CLINIC_TIMEOUT_TIME} npm run dev:clinic:${CLINIC_APP}
  else
    npm run dev
  fi
else
  npm start
fi