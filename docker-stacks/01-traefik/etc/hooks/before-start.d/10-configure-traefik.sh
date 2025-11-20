#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

gomplate \
    -f "${SIMVA_CONFIG_TEMPLATE_HOME}/traefik/traefik/static-conf/traefik.toml" \
    -o "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/traefik.toml"

if [[ $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN == "false" ]]; then
    shlinkCertificates="[[tls.certificates]]
  certFile = \"/etc/traefik/ssl/traefik-shlink-fullchain.pem\"
  keyFile  = \"/etc/traefik/ssl/traefik-shlink-key.pem\"
  "
else 
    shlinkCertificates=""
fi

if [[ ! -d "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/dynamic-config/" ]]; then 
    mkdir "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/dynamic-config/"
fi

#https://blog.roberthallam.org/2020/05/generating-a-traefik-nginx-password-hash-without-htpasswd/
export SIMVA_TRAEFIK_DASHBOARD_HASHED_HTPASSWD_PASSWORD=$(echo ${SIMVA_TRAEFIK_DASHBOARD_PASSWORD} | htpasswd -niB ${SIMVA_TRAEFIK_DASHBOARD_USER})

cat << EOF > "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/dynamic-config/file-provider.toml"
[[tls.certificates]]
  certFile = "/etc/traefik/ssl/traefik-fullchain.pem"
  keyFile = "/etc/traefik/ssl/traefik-key.pem"
  stores = ["default"]
$shlinkCertificates
[tls.stores]
  [tls.stores.default]
    [tls.stores.default.defaultCertificate]
      certFile = "/etc/traefik/ssl/traefik-fullchain.pem"
      keyFile  = "/etc/traefik/ssl/traefik-key.pem"

[tls.options]
  [tls.options.default]
    minVersion = "VersionTLS12"

[http.middlewares]
  [http.middlewares.dashboardAuth.basicAuth]
    # admin:password
    users = [
      "${SIMVA_TRAEFIK_DASHBOARD_HASHED_HTPASSWD_PASSWORD}"
    ]
EOF