# Removing Traefik certificates 
rm "${SIMVA_TLS_HOME}/traefik.pem"
rm "${SIMVA_TLS_HOME}/traefik-key.pem"
rm "${SIMVA_TLS_HOME}/traefik-fullchain.pem"

# Removing Truststore jks file 
rm "${SIMVA_TLS_HOME}/truststore.jks"

# Removing static conf
rm "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/traefik.toml"

# Removing dhparam certificate
rm "${SIMVA_TLS_HOME}/dhparam.pem"