#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_CONTAINER_NAME="keycloak"
export RUN_IN_AS_SPECIFIC_USER="root"

if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} -ge 26 ]]; then 
    if [[ -e "${SIMVA_ROOT_CA_FILE}" ]]; then
        echo "Checking if ${SIMVA_ROOT_CA_FILE} is already imported into ${SIMVA_TRUSTSTORE_FILE}..."

        # Try to extract fingerprint of the certificate already inside the truststore
        set +e
        existing_fingerprint=$(
            "${SIMVA_BIN_HOME}/run-command.sh" keytool -list -keystore "/usr/lib/jvm/java-21-openjdk-21.0.6.0.7-1.el9.x86_64/lib/security/cacerts" \
                -storepass "changeit" \
                -alias "${SIMVA_CA_ALIAS}" -v 2>/dev/null \
            | grep "SHA256:" | awk '{print $2}' | tr -d ':'
        )
        set -e

        # Compute fingerprint of the certificate file
        file_fingerprint=$(openssl x509 -noout -fingerprint -sha256 -in "${SIMVA_ROOT_CA_FILE}" \
            | cut -d'=' -f2 | tr -d ':')

        if [[ -z "${existing_fingerprint}" ]]; then
            echo "No fingerprint found in truststore for alias ${SIMVA_CA_ALIAS} — not imported yet."
            install=true
        else
            echo "Existing fingerprint: ${existing_fingerprint}"
            echo "File fingerprint:     ${file_fingerprint}"
            
            if [[ "${existing_fingerprint}" == "${file_fingerprint}" ]]; then
                install=false
            else
                install=true
            fi
        fi

        if [[ "${install}" == true ]]; then
            echo "Certificates differ — importing into JDK truststore..."

            # Temporarily disable exit-on-error
            launch_bash_options=$-
            set +e

            "${SIMVA_BIN_HOME}/run-command.sh" keytool -importcert \
                -trustcacerts -noprompt -cacerts \
                -storepass "changeit" \
                -file "/root/.keycloak/certs/ca/${SIMVA_ROOT_CA_FILENAME}" \
                -alias "${SIMVA_CA_ALIAS}"

            # Restore -e if it was enabled
            if [[ $launch_bash_options =~ e ]]; then set -e; fi

            echo "Certificate imported into truststore."
        else
            echo "Certificate already up-to-date in truststore — no update needed."
        fi
    fi
fi