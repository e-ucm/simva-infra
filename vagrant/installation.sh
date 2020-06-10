#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

MKCERT_VERSION=1.4.1
MKCERT_DOWNLOAD_URL=https://github.com/FiloSottile/mkcert/releases/download/v${MKCERT_VERSION}/mkcert-v${MKCERT_VERSION}-linux-amd64
MKCERT_SHA256=e116543bfabb4d88010dda8a551a5d01abbdf9b4f2c949c044b862365038f632
curl -sSL "$MKCERT_DOWNLOAD_URL" -o /tmp/mkcert
echo "$MKCERT_SHA256 /tmp/mkcert" | sha256sum -c -
mv /tmp/mkcert /usr/local/bin
chmod +x /usr/local/bin/mkcert

/vagrant/vagrant/from-host.sh

if [[ ! -e "/home/vagrant/01-traefik/ssl/cert.crt" ]]; then
    mkcert -install
    mkcert \
        -cert-file /home/vagrant/01-traefik/ssl/cert.crt \
        -key-file /home/vagrant/01-traefik/ssl/cert.key \
            "traefik.dev.test" \
            "*.external.test" \
            "*.keycloak.external.test" \
            "*.limesurvey.external.test" \
            "*.app.external.test" \
            "localhost" \
            "127.0.0.1" \
            "192.168.253.2"
    cp /home/vagrant/01-traefik/ssl/cert.crt /home/vagrant/01-traefik/ssl/fullchain.pem
    cat "$(mkcert -CAROOT)/rootCA.pem" >> /home/vagrant/01-traefik/ssl/fullchain.pem
    cp "$(mkcert -CAROOT)/rootCA.pem" /home/vagrant/04-minio/CAs/ca.crt
fi

units="00-network 01-traefik 02-keycloak 03-limesurvey 04-minio"
for unit in $units; do
    echo "Launching: $unit"
    pushd "$unit"
    docker-compose up -d
    echo "Wait 30s (XXX this must be done properly waiting for the services)"
    sleep 30
    popd
done