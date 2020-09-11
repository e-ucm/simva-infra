#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

set +e
which mkcert >/dev/null
mkcert_installed=$?
set -e

if [[ ! -z ${mkcert_installed} ]]; then
    MKCERT_VERSION=v1.4.1
    MKCERT_DOWNLOAD_URL=https://github.com/FiloSottile/mkcert/releases/download/${MKCERT_VERSION}/mkcert-${MKCERT_VERSION}-linux-amd64
    MKCERT_SHA256=e116543bfabb4d88010dda8a551a5d01abbdf9b4f2c949c044b862365038f632
    curl -sSL "$MKCERT_DOWNLOAD_URL" > /tmp/mkcert
    echo "$MKCERT_SHA256 /tmp/mkcert" | sha256sum -c -
    mv /tmp/mkcert /usr/local/bin
    chmod +x /usr/local/bin/mkcert
fi

apt-get install --no-install-recommends -y \
    jq \
    openjdk-8-jre-headless

cp -a /vagrant/docker-stacks /home/vagrant