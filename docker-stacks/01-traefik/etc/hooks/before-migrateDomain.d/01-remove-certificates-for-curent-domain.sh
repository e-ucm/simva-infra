${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_TLS_HOME}/traefik.pem" \
    "${SIMVA_TLS_HOME}/traefik-key.pem" \
    "${SIMVA_TLS_HOME}/traefik-fullchain.pem" \
    "${SIMVA_TLS_HOME}/truststore.jks" \
    "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/traefik.toml" \
    "${SIMVA_TLS_HOME}/dhparam.pem"