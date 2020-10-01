#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

set +e
which gomplate >/dev/null
gomplate_installed=$?
set -e

echo "PATH: $PATH"
if [[ ${gomplate_installed} -ne 0 ]]; then
    GOMPLATE_VERSION=v3.8.0
    GOMPLATE_DOWNLOAD_URL=https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64
    GOMPLATE_SHA256SUMS_URL=https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/checksums-${GOMPLATE_VERSION}_sha256.txt
    curl -sSL "$GOMPLATE_SHA256SUMS_URL" > /tmp/gomplate-sha256sums
    curl -sSL "$GOMPLATE_DOWNLOAD_URL" > /tmp/gomplate_linux-amd64
    cat /tmp/gomplate-sha256sums | grep -E 'linux-amd64$' | sed -e 's/bin\//\/tmp\//' | sha256sum -c -
    mv /tmp/gomplate_linux-amd64 ${SIMVA_PROJECT_DIR}/bin/gomplate
    chmod +x ${SIMVA_PROJECT_DIR}/bin/gomplate
fi
