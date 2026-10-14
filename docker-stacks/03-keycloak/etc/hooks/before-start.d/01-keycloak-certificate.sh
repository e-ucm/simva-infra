# Only proceed if we have both certificate and key
if [[ -e "${SIMVA_TRAEFIK_CERT_FILE}" && -e "${SIMVA_TRAEFIK_KEY_FILE}" ]]; then
    echo "Checking PKCS#12 file: ${SIMVA_KEYCLOAK_CERT_FILE}"

    tmp_p12="/tmp/simva_tmp_keycloak.p12"

    # Always generate a temporary version for comparison
    openssl pkcs12 -export \
        -in "${SIMVA_TRAEFIK_CERT_FILE}" \
        -inkey "${SIMVA_TRAEFIK_KEY_FILE}" \
        -out "${tmp_p12}" \
        -name keycloak \
        -passout pass:changeit >/dev/null 2>&1

    if [[ ! -e "${SIMVA_KEYCLOAK_CERT_FILE}" ]]; then
        echo "PKCS#12 file does not exist — creating it."
        cp "${tmp_p12}" "${SIMVA_KEYCLOAK_CERT_FILE}"
        rm -f "${tmp_p12}"
        exit 0
    fi

    # Compute sha256 of existing P12
    existing_sha=$(sha256sum "${SIMVA_KEYCLOAK_CERT_FILE}" | awk '{print $1}')

    # Compute sha256 of newly generated P12
    tmp_sha=$(sha256sum "${tmp_p12}" | awk '{print $1}')

    echo "Existing P12 sha256sum: ${existing_sha}"
    echo "New P12 sha256sum:      ${tmp_sha}"

    if [[ "${existing_sha}" == "${tmp_sha}" ]]; then
        echo "PKCS#12 file is up-to-date — no regeneration needed."
        rm -f "${tmp_p12}"
    else
        echo "PKCS#12 content differs — updating file."
        cp "${tmp_p12}" "${SIMVA_KEYCLOAK_CERT_FILE}"
        rm -f "${tmp_p12}"
        echo "PKCS#12 updated."
    fi
fi
