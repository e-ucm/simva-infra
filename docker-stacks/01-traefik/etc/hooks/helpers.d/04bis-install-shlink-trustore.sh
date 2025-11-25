#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x


if [[ $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN  == "false" ]]; then 
    if [[ ! -e "${SIMVA_TRUSTSTORE_SHLINK_FILE}" ]]; then
        keytool -importcert -trustcacerts -noprompt \
            -storepass ${SIMVA_TRUSTSTORE_PASSWORD} \
            -keystore ${SIMVA_TRUSTSTORE_SHLINK_FILE} \
            -alias ${SIMVA_TRUSTSTORE_CA_ALIAS}  \
            -file ${SIMVA_ROOT_CA_FILE}
        set +e
        _check_checksum $SIMVA_TLS_HOME "${SIMVA_SHA256SUMS_TLS_HOME}/traefik-shlink-trustore-sha256sums" $SIMVA_TRUSTSTORE_FILENAME
        set -e
    fi
fi