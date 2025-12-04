${SIMVA_BIN_HOME}/purge-file-if-exist.sh \
    "${SIMVA_TRAEFIK_CERT_FILE}" \
    "${SIMVA_TRAEFIK_KEY_FILE}" \
    "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}" \
    "${SIMVA_TRUSTSTORE_FILE}" \
    ${SIMVA_ROOT_CA_FILE} \
    ${SIMVA_ROOT_CA_KEY_FILE} \
    "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf/traefik.toml" \
    "${SIMVA_DHPARAM_FILE}"