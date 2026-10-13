#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1 && pwd)"
STACKS="${ROOT}/docker-stacks"
export SIMVA_PROJECT_DIR="${STACKS}"

source "${STACKS}/etc/simva.d/simva-env.sh"
source "${STACKS}/etc/simva.d/simva-env.dev.sh"
source "${STACKS}/etc/simva.install.d/simva-env.sh"

HOSTS_FILE="${HOSTS_FILE:-/etc/hosts}"
MARKER_START="# SIMVA_CI_HOSTS_START"
MARKER_END="# SIMVA_CI_HOSTS_END"

sed -i "/^${MARKER_START}$/,/^${MARKER_END}$/d" "$HOSTS_FILE" 2>/dev/null || true
touch "$HOSTS_FILE"

entries=$({
  for var in $(compgen -v | grep '^SIMVA_.*_HOST_SUBDOMAIN$'); do
    subdomain="${!var}"
    if [[ -n "${subdomain}" ]]; then
      echo "127.0.0.1 ${subdomain}.${SIMVA_EXTERNAL_DOMAIN}"
    fi
  done
  echo "127.0.0.1 ${SIMVA_EXTERNAL_DOMAIN}"
  echo "127.0.0.1 ${SIMVA_SHLINK_EXTERNAL_DOMAIN}"
  echo "127.0.0.1 ${SIMVA_PORTAINER_HOST_SUBDOMAIN:-portainer}.${SIMVA_EXTERNAL_DOMAIN}"
} | sort -u)

{
  echo "$MARKER_START"
  echo "$entries"
  echo "$MARKER_END"
} >> "$HOSTS_FILE"

echo "Updated ${HOSTS_FILE}:"
awk "/^${MARKER_START}$/{print} /^127.0.0.1 .*\.${SIMVA_EXTERNAL_DOMAIN}/{print}" "$HOSTS_FILE"