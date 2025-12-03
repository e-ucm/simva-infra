#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_TRUSTSTORE_FILE}" ]]; then
    keytool -importcert -trustcacerts -noprompt \
        -storepass ${SIMVA_TRUSTSTORE_PASSWORD} \
        -keystore ${SIMVA_TRUSTSTORE_FILE} \
        -alias ${SIMVA_TRUSTSTORE_CA_ALIAS}  \
        -file ${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}
    source ${SIMVA_HOME}/bin/check-checksum.sh;
    set +e
    _check_checksum $SIMVA_TLS_HOME "${SIMVA_SHA256SUMS_TLS_HOME}/traefik-trustore-sha256sums" $SIMVA_TRUSTSTORE_FILENAME
    set -e
fi