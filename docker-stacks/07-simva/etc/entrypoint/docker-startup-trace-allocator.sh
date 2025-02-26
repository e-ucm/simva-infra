if [ ! -e "/usr/local/share/ca-certificates/internal-CA.crt" ]; then
  cp /var/lib/simva/ca/rootCA.pem "/usr/local/share/ca-certificates/internal-CA.crt";
  update-ca-certificates;
  cat /etc/ca-certificates.conf;
fi;
admin_username=$(echo ${SIMVA_API_ADMIN_USERNAME:-admin} | tr '[:upper:]' '[:lower:]');
json="{\"username\":\"${admin_username}\",\"password\":\"${SIMVA_API_ADMIN_PASSWORD:-password}\"}";
/bin/wait-available-with-connection.sh 'SIMVA API' 'https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN:-simva-api}.${SIMVA_EXTERNAL_DOMAIN:-external.test}/users/login' $${json} 'token' $${NODE_EXTRA_CA_CERTS};
cd "/home/node/app"

#start trace allocator
echo "${NODE_ENV:-production}"
if [[ "${NODE_ENV:-production}" == "development" ]]; then
  npm run dev
else
  npm start
fi