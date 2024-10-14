#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -e "${SIMVA_TLS_HOME}/limesurvey.pem" ]]; then
    openssl genrsa -out ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY} 2048
    openssl req \
        -subj "${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT_SUBJ}" \
        -new -key ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY} \
        -out ${SIMVA_TLS_HOME}/limesurvey.csr
    openssl x509 -req \
        -in ${SIMVA_TLS_HOME}/limesurvey.csr \
        -signkey ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY} \
        -out ${SIMVA_TLS_HOME}/limesurvey.pem -days 365

    #mkcert -install \
    #    -cert-file ${SIMVA_TLS_HOME}/limesurvey.pem \
    #    -csr ${SIMVA_TLS_HOME}/limesurvey.csr
fi;
if  [[ ! -e "${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT}" ]]; then
    export CAROOT="${SIMVA_TLS_HOME}/ca"
    cp ${SIMVA_TLS_HOME}/limesurvey.pem ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT}
    cat ${CAROOT}/rootCA.pem >> ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT}
    chmod a+r ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY}
fi