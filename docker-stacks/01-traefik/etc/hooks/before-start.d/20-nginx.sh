#!/bin/bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ "${SIMVA_ENVIRONMENT}" != "development" ]]; then
  exit 0;
fi
if [[ "${SIMVA_DEV_LOAD_BALANCER}" == "false" ]]; then
  exit 0;
fi
OUTPUT_FILE="${SIMVA_DATA_HOME}/traefik/nginx_upstream_hosts.txt"
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "${SIMVA_EXTERNAL_DOMAIN};" > "$OUTPUT_FILE"
for var in $(compgen -v | grep '^SIMVA_.*_HOST_SUBDOMAIN$'); do
  if [[ "$var" == *"NGINX"* ]] || [[ "$var" == *"MINIO_HOST"* ]] || [[ "$var" == *"SHLINK"* && $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN == false ]]; then
    continue
  else 
    subdomain="${!var}"
    if [[ "$subdomain" != "" ]]; then
      echo "    server_name  ${subdomain}.${SIMVA_EXTERNAL_DOMAIN};" >> "$OUTPUT_FILE"
    fi
  fi
done
export SIMVA_SERVER_LIST_NAME=$(cat "$OUTPUT_FILE");