if [ ! -e "/usr/local/share/ca-certificates/internal-CA.crt" ]; then
  cp /var/lib/simva/ca/rootCA.pem "/usr/local/share/ca-certificates/internal-CA.crt";
  update-ca-certificates;
  cat /etc/ca-certificates.conf;
fi;
mkdir -p ${SIMVA_STORAGE_PATH:-/storage} && cd /home/node/app

#start api
echo "${NODE_ENV:-production}"
if [[ "${NODE_ENV:-production}" == "development" ]]; then
  npm run dev
else
  npm start
fi