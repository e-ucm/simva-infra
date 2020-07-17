#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

IPYAUTH_VERSION="0.2.6-eucm.1"
IPYAUTH_DOWNLOAD_URL="https://github.com/krallin/tini/releases/download/${IPYAUTH_VERSION}/ipyauth-${IPYAUTH_VERSION}.tar.gz"
IPYAUTH_SHA256SUM="c3145bafd5def59ab3c9cfb5760d0ceaabe465f4fc96d16545d12ec0c78cff1b"

if [[ ! -e "${SIMVA_DATA_HOME}/anaconda/packages/ipyauth-${IPYAUTH_VERSION}.tar.gz" ]]; then
    curl -sSL "$${IPYAUTH_DOWNLOAD_URL}" > "${SIMVA_DATA_HOME}/anaconda/packages/ipyauth-${IPYAUTH_VERSION}.tar.gz"
    echo "$IPYAUTH_SHA256SUM ${SIMVA_DATA_HOME}/anaconda/packages/ipyauth-${IPYAUTH_VERSION}.tar.gz" | sha256sum -c -
fi

if [[ ! -e "${SIMVA_DATA_HOME}/anaconda/packages/ipyauth.tar.gz" ]]; then
    cp "${SIMVA_DATA_HOME}/anaconda/packages/ipyauth-${IPYAUTH_VERSION}.tar.gz" "${SIMVA_DATA_HOME}/anaconda/packages/ipyauth.tar.gz"
fi