#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

if [[ ! -d "${SIMVA_SHA256SUMS_TLS_HOME}" ]]; then
    mkdir ${SIMVA_SHA256SUMS_TLS_HOME}
fi

source ${SIMVA_HOME}/bin/check-checksum.sh;
###################################
# ROOT CA AND TRAEFIK CERT UPDATE #
###################################
# Check if root CA cert have been updated
rootCA_file_exists=false;
if [[ -f "${SIMVA_ROOTCA_SHA256SUMS_FILE}" ]]; then 
    rootCA_file_exists=true;
fi
set +e
_check_checksum $SIMVA_ROOT_CA "${SIMVA_ROOTCA_SHA256SUMS_FILE}" "${SIMVA_ROOT_CA_FILENAME}"
ret=$?
set -e
echo $ret

rootCA_updated=false;
if [[ $ret != 0 ]]; then
    rootCA_updated=true;
fi

# Check if traefik cert have been updated
traefik_file_exists=false;
if [[ -f "${SIMVA_TRAEFIK_SHA256SUMS_FILE}" ]]; then 
    traefik_file_exists=true;
fi
set +e
_check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_CERT_FILENAME}"
ret=$?
set -e
echo $ret
traefik_cert_updated=false;
if [[ $ret != 0 ]]; then
    traefik_cert_updated=true;
fi

# Update traefik fullchain cert if root CA or traefik cert have been updated
traefik_fullchain_cert_automatically_updated=false;
if [[ $rootCA_updated == "true" || $traefik_cert_updated == "true" ]]; then
    if [[ $rootCA_file_exists == "true" && $traefik_file_exists == "true" ]]; then
        read -p "Are you sure that the root CA has been updated ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    fi
    "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
    "${HELPERS_STACK_HOME}/03-install-fullchain.sh"
    traefik_fullchain_cert_automatically_updated=true;
fi

# Update truststore if traefik fullchain cert have been updated
traefik_fullchain_file_exists=false;
if [[ -f "${SIMVA_TRAEFIK_FULLCHAIN_SHA256SUMS_FILE}" ]]; then 
    traefik_fullchain_file_exists=true;
fi
traefik_fullchain_cert_updated=false;
if [[ ! traefik_fullchain_cert_automatically_updated == "true" ]]; then
    set +e
    _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_FULLCHAIN_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILENAME}"
    ret=$?
    set -e
    echo $ret
    if [[ $ret != 0 ]]; then
        traefik_fullchain_cert_updated=true;
    fi
fi

###################
# TRUSTORE UPDATE #
###################
# Update truststore if traefik fullchain cert have been updated
if [[ $traefik_fullchain_cert_updated == "true" || traefik_fullchain_cert_automatically_updated == "true" ]]; then
    if [[ $traefik_fullchain_file_exists == "true" && ! $traefik_fullchain_cert_automatically_updated == "true" ]]; then
        read -p "Are you sure that the traefik fullchain has been updated ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        #"$SIMVA_HOME/simva" backup "$CURRENT_STACK";
    fi
    rm -rf ${SIMVA_TRUSTSTORE_FILE}
    "${HELPERS_STACK_HOME}/04-install-trustore.sh"
fi

###########################################
# TRAEFIK SHLINK CERT AND TRUSTORE UPDATE #
###########################################
if [[ $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN  == "false" ]]; then
    # Check if traefik shlink cert have been updated
    traefik_shlink_fullchain_cert_automatically_updated=false;
    traefik_shlink_file_exists=false;
    if [[ -f "${SIMVA_TRAEFIK_SHLINK_SHA256SUMS_FILE}" ]]; then 
        traefik_shlink_file_exists=true;
    fi
    set +e
    _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHLINK_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_SHLINK_CERT_FILENAME}"
    ret=$?
    set -e
    echo $ret
    traefik_shlink_cert_updated=false;
    if [[ $ret != 0 ]]; then
        traefik_shlink_cert_updated=true;
    fi
    if [[ $traefik_shlink_cert_updated == "true" || $rootCA_updated == "true" ]]; then 
        "${HELPERS_STACK_HOME}/03bis-install-shlink-fullchain.sh"
        traefik_shlink_fullchain_cert_automatically_updated=true;
    fi

    # Update truststore if traefik fullchain cert have been updated
    traefik_shlink_fullchain_file_exists=false;
    if [[ -f "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_SHA256SUMS_FILE}" ]]; then 
        traefik_shlink_fullchain_file_exists=true;
    fi
    traefik_shlink_fullchain_cert_updated=false;
    if [[ ! traefik_shlink_fullchain_cert_automatically_updated == "true" ]]; then
        set +e
        _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILENAME}"
        ret=$?
        set -e
        echo $ret
        if [[ $ret != 0 ]]; then
            traefik_shlink_fullchain_cert_updated=true;
        fi
    fi

    ###################
    # TRUSTORE UPDATE #
    ###################
    # Update truststore if traefik fullchain cert have been updated
    if [[ $traefik_shlink_fullchain_cert_updated == "true" || traefik_shlink_fullchain_cert_automatically_updated == "true" ]]; then
        if [[ $traefik_shlink_file_exists == "true" && ! $traefik_shlink_fullchain_cert_automatically_updated == "true" ]]; then
            read -p "Are you sure that the traefik shlink fullchain has been updated ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            #"$SIMVA_HOME/simva" backup "$CURRENT_STACK";
        fi
        rm -rf ${SIMVA_TRUSTSTORE_SHLINK_FILE}
        "${HELPERS_STACK_HOME}/04bis-install-shlink-trustore.sh"
    fi
fi