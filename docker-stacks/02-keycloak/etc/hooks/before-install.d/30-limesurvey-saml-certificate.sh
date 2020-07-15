#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_TLS_HOME}/limesurvey.pem" ]]; then
    openssl genrsa -out ${SIMVA_TLS_HOME}/limesurvey-key.pem 2048
    openssl req \
        -subj "${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT_SUBJ}" \
        -new -key ${SIMVA_TLS_HOME}/limesurvey-key.pem \
        -out ${SIMVA_TLS_HOME}/limesurvey.csr

    export CAROOT="${SIMVA_TLS_HOME}/ca"
    mkcert \
        -cert-file ${SIMVA_TLS_HOME}/limesurvey.pem \
        -csr ${SIMVA_TLS_HOME}/limesurvey.csr

    cp ${SIMVA_TLS_HOME}/limesurvey.pem ${SIMVA_TLS_HOME}/limesurvey-fullchain.pem
    cat ${SIMVA_TLS_HOME}/ca/rootCA.pem >> ${SIMVA_TLS_HOME}/limesurvey-fullchain.pem
fi