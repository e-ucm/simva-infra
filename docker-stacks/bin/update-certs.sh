if [[ ${SIMVA_TLS_GENERATE_SELF_SIGNED} == "false" ]]; then
    echo "Updating certificates..."
    if [[ -f "${SIMVA_HOME}/../../${SIMVA_EXTERNAL_DOMAIN}.pem" ]]; then
        openssl x509 -checkend 0 -noout -in "${SIMVA_HOME}/../../${SIMVA_EXTERNAL_DOMAIN}.pem" > /dev/null || {
            echo "The root CA certificate for ${SIMVA_EXTERNAL_DOMAIN} is expired. Please update it before starting the stack."
            exit 1
        }
        if [[ ! -f "${SIMVA_HOME}/../../${SIMVA_EXTERNAL_DOMAIN}-privkey.pem" ]]; then
            echo "The private key ${SIMVA_EXTERNAL_DOMAIN}-privkey.pem is missing. Please provide a new one to update the certificates."
            exit 1
        fi
        if [[ ! -f "${SIMVA_HOME}/../../${SIMVA_EXTERNAL_DOMAIN}-fullchain.pem" ]]; then
            echo "The full chain certificate ${SIMVA_EXTERNAL_DOMAIN}-fullchain.pem is missing. Please provide a new one to update the certificates."
            exit 1
        fi
        cp "${SIMVA_HOME}/../../${SIMVA_EXTERNAL_DOMAIN}.pem" "${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_CERT_FILENAME}"
        cp "${SIMVA_HOME}/../../${SIMVA_EXTERNAL_DOMAIN}-privkey.pem" "${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_KEY_FILENAME}"
        cp "${SIMVA_HOME}/../../${SIMVA_EXTERNAL_DOMAIN}-fullchain.pem" "${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILENAME}"
    else 
        echo "The root CA certificate ${SIMVA_EXTERNAL_DOMAIN}.pem is missing. Please provide a new one to update the certificates."
        exit 1
    fi
    if [[ ${SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN} ]]; then 
        if [[ -f "${SIMVA_HOME}/../../${SIMVA_SHLINK_EXTERNAL_DOMAIN}.pem" ]]; then
            openssl x509 -checkend 0 -noout -in "${SIMVA_HOME}/../../${SIMVA_SHLINK_EXTERNAL_DOMAIN}.pem" > /dev/null || {
                echo "The root CA certificate for ${SIMVA_SHLINK_EXTERNAL_DOMAIN} is expired. Please update it before starting the stack."
                exit 1
            }
            if [[ ! -f "${SIMVA_HOME}/../../${SIMVA_SHLINK_EXTERNAL_DOMAIN}-privkey.pem" ]]; then
                echo "The private key ${SIMVA_SHLINK_EXTERNAL_DOMAIN}-privkey.pem is missing. Please provide a new one to update the certificates."
                exit 1
            fi
            if [[ ! -f "${SIMVA_HOME}/../../${SIMVA_SHLINK_EXTERNAL_DOMAIN}-fullchain.pem" ]]; then
                echo "The full chain certificate ${SIMVA_SHLINK_EXTERNAL_DOMAIN}-fullchain.pem is missing. Please provide a new one to update the certificates."
                exit 1
            fi
            cp "${SIMVA_HOME}/../../${SIMVA_SHLINK_EXTERNAL_DOMAIN}.pem" "${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_SHLINK_CERT_FILENAME}"
            cp "${SIMVA_HOME}/../../${SIMVA_SHLINK_EXTERNAL_DOMAIN}-fullchain.pem" "${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILENAME}"
            cp "${SIMVA_HOME}/../../${SIMVA_SHLINK_EXTERNAL_DOMAIN}-privkey.pem" "${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_SHLINK_KEY_FILENAME}"
        else 
            echo "The root CA certificate ${SIMVA_SHLINK_EXTERNAL_DOMAIN}.pem is missing. Please provide a new one to update the certificates."
            exit 1
        fi
    fi
fi
echo "Certificates updated successfully."