#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ${SIMVA_LIMESURVEY_VERSION:0:1} > 5 ]]; then
    echo "Nothing to do";
else
    if [[ ! -e "${SIMVA_LIMESURVEY_CERT_FILE}" ]]; then
        openssl genrsa -out ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY} 2048
        openssl req \
            -subj "${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT_SUBJ}" \
            -new -key ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY} \
            -out ${SIMVA_LIMESURVEY_CERT_CRS_FILE}
        openssl x509 -req \
            -in ${SIMVA_LIMESURVEY_CERT_CRS_FILE} \
            -signkey ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY} \
            -out ${SIMVA_LIMESURVEY_CERT_FILE} -days 365
    fi
    if  [[ ! -e "${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT}" ]]; then
        cp ${SIMVA_LIMESURVEY_CERT_FILE} ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT}
        cat "${SIMVA_ROOT_CA_FILE}" >> ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT}
        chmod ${SIMVA_CERT_FILE_MOD} ${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY}
    fi
fi