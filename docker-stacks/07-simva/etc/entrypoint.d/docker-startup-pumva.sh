#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

cd /home/node/app

#start api
echo "${NODE_ENV}"
if [[ "${NODE_ENV}" == "development" ]]; then
    npm run dev
  fi
else
  npm start
fi