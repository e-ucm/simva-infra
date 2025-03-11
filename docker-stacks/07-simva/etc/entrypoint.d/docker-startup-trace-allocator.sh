if [ ! -e "/usr/local/share/ca-certificates/internal-CA.crt" ]; then
  cp /var/lib/simva/ca/rootCA.pem "/usr/local/share/ca-certificates/internal-CA.crt";
  update-ca-certificates;
  cat /etc/ca-certificates.conf;
fi;

admin_username=$(echo ${SIMVA_USER:-admin} | tr '[:upper:]' '[:lower:]');
json="{\"username\":\"${admin_username}\",\"password\":\"${SIMVA_PASSWORD:-password}\"}";

set +e
/bin/wait-available-with-connection.sh 'SIMVA API' "${SIMVA_PROTOCOL}://${SIMVA_HOST}:${SIMVA_PORT}/users/login" ${json} 'token' ${NODE_EXTRA_CA_CERTS};
ret=$?
set -e
echo $ret

if [[ $ret == 0 ]]; then 
  cd "/home/node/app"

  #start trace allocator
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
else 
  echo "SIMVA API not running. Exit."
  exit 1
fi