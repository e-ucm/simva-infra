cd /home/node/app

#start front
echo "${NODE_ENV:-production}"
if [[ "${NODE_ENV:-production}" == "development" ]]; then
  if [[ "${ENABLE_DEBUG_PROFILING:-false}" == "true" ]]; then
    npm run dev:profiling
  else 
    npm run dev
  fi
else
  npm start
fi