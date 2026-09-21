#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# --- Config ---
ENV_INSTALL_PATH="../docker-stacks/etc/simva.install.d/simva-env.sh"
ENV_FOLDER="../docker-stacks/etc/simva.d"
ENV_FILE="simva-env.sh"
ENV_PATH="$ENV_FOLDER/$ENV_FILE"
ENV_DEV_FILE="simva-env.dev.sh"
ENV_DEV_PATH="$ENV_FOLDER/$ENV_DEV_FILE"
OUTPUT_FILE="hostnames.txt"
OUTPUT_EXTERNAL_IP_FILE="external_ip.txt"
export SIMVA_PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# --- Load .env ---
if [[ ! -f "$ENV_INSTALL_PATH" ]]; then
  echo "Error: $ENV_INSTALL_PATH not found!"
  exit 1
fi

if [[ ! -f "$ENV_PATH" ]]; then
  echo "Error: $ENV_PATH not found!"
  exit 1
fi

set -a
source "$ENV_PATH"
source "$ENV_INSTALL_PATH"
if [[ $SIMVA_ENVIRONMENT == "development" ]]; then
    echo "IN DEV"
    if [[ ! -f "$ENV_DEV_PATH" ]]; then
        echo "Error: $ENV_DEV_PATH not found!"
        exit 1
    else 
        source "$ENV_DEV_PATH"
    fi
fi
set +a

# Check mandatory variable
if [[ -z "${SIMVA_EXTERNAL_DOMAIN:-}" ]]; then
  echo "Error: SIMVA_EXTERNAL_DOMAIN is not set in $ENV_PATH"
  exit 1
fi

# --- Build external ip ---
> "$OUTPUT_EXTERNAL_IP_FILE"  # empty the file
echo "${SIMVA_HOST_EXTERNAL_IP}" >> "$OUTPUT_EXTERNAL_IP_FILE"
# --- Build hostnames ---
> "$OUTPUT_FILE"  # empty the file
echo "${SIMVA_TRAEFIK_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}" >> "$OUTPUT_FILE"
if [[ $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN == "false" ]]; then
  echo "${SIMVA_SHLINK_EXTERNAL_DOMAIN}" >> "$OUTPUT_FILE"
fi
echo "${SIMVA_EXTERNAL_DOMAIN}" >> "$OUTPUT_FILE"

for var in $(compgen -v | grep '^SIMVA_.*_HOST_SUBDOMAIN$'); do
  subdomain="${!var}"
  if [[ -n "$subdomain" ]]; then
    echo "${subdomain}.${SIMVA_EXTERNAL_DOMAIN}" >> "$OUTPUT_FILE"
  fi
done

echo "$OUTPUT_FILE generated:"
cat "$OUTPUT_FILE"