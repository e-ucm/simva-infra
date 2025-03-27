cd /home/node/app

#start front
echo "${NODE_ENV:-production}"
if [[ "${NODE_ENV:-production}" == "development" ]]; then
  if [[ "${ENABLE_DEBUG_PROFILING:-false}" == "true" ]]; then
    exec clinic ${CLINIC_APP} --dest ${PROFILING_FOLDER} --name ${CLINIC_APP}-report-$(date +%s) -- node ./bin/www
  else
    npm run dev
  fi
else
  npm start
fi