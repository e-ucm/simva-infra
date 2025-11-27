if [[ ! -e "${SIMVA_SSO_CERT_FILE}" ]]; then
    openssl pkcs12 -export \
        -in ${SIMVA_TRAEFIK_CERT_FILE} \
        -inkey ${SIMVA_TRAEFIK_KEY_FILE} \
        -out ${SIMVA_KEYCLOAK_CERT_FILE} \
        -name keycloak \
        -passout pass:changeit
fi