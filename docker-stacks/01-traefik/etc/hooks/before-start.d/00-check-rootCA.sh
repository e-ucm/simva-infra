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

# Check root CA certificate
rootCA_updated=false;

# First, ensure root CA file exists
if [[ ! -f "${SIMVA_ROOT_CA_FILE}" ]]; then
    "${HELPERS_STACK_HOME}/01-install-rootCA.sh"
    rootCA_updated=true;
fi

# Check if root CA certificate is expired
if [[ -f "${SIMVA_ROOT_CA_FILE}" ]] && [[ "$rootCA_updated" == "false" ]]; then
    set +e
    "${SIMVA_HOME}/bin/check-certificate-valid.sh" "${SIMVA_ROOT_CA_FILE}"
    ret=$?
    set -e
    if [[ $ret != 0 ]]; then
        if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
            read -p "The root CA certificate is expired. Do you want to automatically update it ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
            "${HELPERS_STACK_HOME}/01-install-rootCA.sh"
            rootCA_updated=true;
        else 
            echo "The root CA certificate is expired. Please update it before starting the stack."
            exit 1
        fi
    fi
fi

# Check if root CA checksum changed (external update)
if [[ "$rootCA_updated" == "false" ]]; then
    if [[ ! -f "${SIMVA_ROOTCA_SHA256SUMS_FILE}" ]]; then
        set +e
        _check_checksum $SIMVA_ROOT_CA "${SIMVA_ROOTCA_SHA256SUMS_FILE}" "${SIMVA_ROOT_CA_FILENAME}"
        set -e
    fi
    set +e
    _check_checksum $SIMVA_ROOT_CA "${SIMVA_ROOTCA_SHA256SUMS_FILE}" "${SIMVA_ROOT_CA_FILENAME}"
    ret=$?
    set -e
    if [[ $ret != 0 ]]; then
        rootCA_updated=true;
    fi
fi

# Check traefik certificate
traefik_cert_updated=false;

# First, ensure traefik cert file exists
if [[ ! -f "${SIMVA_TRAEFIK_CERT_FILE}" ]]; then
    "${HELPERS_STACK_HOME}/02-install-traefik-cert.sh"
    traefik_cert_updated=true;
fi

# Check if traefik certificate is expired
if [[ -f "${SIMVA_TRAEFIK_CERT_FILE}" ]] && [[ "$traefik_cert_updated" == "false" ]]; then
    set +e
    "${SIMVA_HOME}/bin/check-certificate-valid.sh" "${SIMVA_TRAEFIK_CERT_FILE}"
    ret=$?
    set -e
    if [[ $ret != 0 ]]; then
        if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
            read -p "The traefik certificate is expired. Do you want to automatically update it ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
            "${HELPERS_STACK_HOME}/02-install-traefik-cert.sh"
            traefik_cert_updated=true;
        else 
            echo "The traefik certificate is expired. Please update it before starting the stack."
            exit 1
        fi
    fi
fi

# Check if traefik cert checksum changed (external update)
if [[ "$traefik_cert_updated" == "false" ]]; then
    if [[ ! -f "${SIMVA_TRAEFIK_SHA256SUMS_FILE}" ]]; then
        set +e
        _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_CERT_FILENAME}"
        set -e
    fi
    set +e
    _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_CERT_FILENAME}"
    ret=$?
    set -e
    if [[ $ret != 0 ]]; then
        traefik_cert_updated=true;
    fi
fi

# Update traefik fullchain cert if root CA or traefik cert have been updated
traefik_fullchain_cert_automatically_updated=false;
if [[ $rootCA_updated == "true" || $traefik_cert_updated == "true" ]] && [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
    read -p "Root CA or traefik cert has been updated. Do you want to regenerate the fullchain ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
    "${HELPERS_STACK_HOME}/03-install-fullchain.sh"
    traefik_fullchain_cert_automatically_updated=true;
fi

# Check traefik fullchain certificate
traefik_fullchain_cert_updated=false;

# First, ensure traefik fullchain cert file exists
if [[ ! -f "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}" ]]; then
    "${HELPERS_STACK_HOME}/03-install-fullchain.sh"
    traefik_fullchain_cert_automatically_updated=true;
fi

# Check if traefik fullchain certificate is expired (only if not already updated)
if [[ -f "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}" ]] && [[ "$traefik_fullchain_cert_automatically_updated" == "false" ]]; then
    set +e
    "${SIMVA_HOME}/bin/check-certificate-valid.sh" "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE}"
    ret=$?
    set -e
    if [[ $ret != 0 ]]; then
        if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
            read -p "The traefik fullchain certificate is expired. Do you want to automatically update it ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
            "${HELPERS_STACK_HOME}/03-install-fullchain.sh"
            traefik_fullchain_cert_automatically_updated=true;
        else
            echo "The traefik fullchain certificate is expired. Please update it before starting the stack."
            exit 1
        fi
    fi
fi

# Check if traefik fullchain cert checksum changed (external update)
if [[ "$traefik_fullchain_cert_automatically_updated" == "false" ]]; then
    if [[ ! -f "${SIMVA_TRAEFIK_FULLCHAIN_SHA256SUMS_FILE}" ]]; then
        set +e
        _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_FULLCHAIN_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILENAME}"
        set -e
    fi
    set +e
    _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_FULLCHAIN_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILENAME}"
    ret=$?
    set -e
    if [[ $ret != 0 ]]; then
        traefik_fullchain_cert_updated=true;
    fi
fi

###################
# TRUSTORE UPDATE #
###################
# Update truststore if traefik fullchain cert have been updated
if [[ $traefik_fullchain_cert_updated == "true" || $traefik_fullchain_cert_automatically_updated == "true" ]] && [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
    read -p "Traefik fullchain has been updated. Do you want to regenerate the truststore ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
    rm -rf ${SIMVA_TRUSTSTORE_FILE}
    "${HELPERS_STACK_HOME}/04-install-trustore.sh"
fi

###########################################
# TRAEFIK SHLINK CERT AND TRUSTORE UPDATE #
###########################################
if [[ $SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN == "false" ]]; then
    traefik_shlink_fullchain_cert_automatically_updated=false;
    traefik_shlink_cert_updated=false;

    # First, ensure traefik shlink cert file exists
    if [[ ! -f "${SIMVA_TRAEFIK_SHLINK_CERT_FILE}" ]]; then
        "${HELPERS_STACK_HOME}/02bis-install-shlink-wildcard-certificate.sh"
        traefik_shlink_cert_updated=true;
    fi

    # Check if traefik shlink certificate is expired
    if [[ -f "${SIMVA_TRAEFIK_SHLINK_CERT_FILE}" ]] && [[ "$traefik_shlink_cert_updated" == "false" ]]; then
        set +e
        "${SIMVA_HOME}/bin/check-certificate-valid.sh" "${SIMVA_TRAEFIK_SHLINK_CERT_FILE}"
        ret=$?
        set -e
        if [[ $ret != 0 ]]; then
            if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
                read -p "The traefik shlink certificate is expired. Do you want to automatically update it ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
                "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
                "${HELPERS_STACK_HOME}/02bis-install-shlink-wildcard-certificate.sh"
                traefik_shlink_cert_updated=true;
            else 
                echo "The traefik shlink certificate is expired. Please update it before starting the stack."
                exit 1
            fi
        fi
    fi

    # Check if traefik shlink cert checksum changed (external update)
    if [[ "$traefik_shlink_cert_updated" == "false" ]]; then
        if [[ ! -f "${SIMVA_TRAEFIK_SHLINK_SHA256SUMS_FILE}" ]]; then
            set +e
            _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHLINK_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_SHLINK_CERT_FILENAME}"
            set -e
        fi
        set +e
        _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHLINK_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_SHLINK_CERT_FILENAME}"
        ret=$?
        set -e
        if [[ $ret != 0 ]]; then
            traefik_shlink_cert_updated=true;
        fi
    fi

    # Update shlink fullchain if shlink cert or root CA updated
    if [[ $traefik_shlink_cert_updated == "true" || $rootCA_updated == "true" ]] && [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then 
        read -p "Traefik shlink cert or root CA has been updated. Do you want to regenerate the shlink fullchain ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
        "${HELPERS_STACK_HOME}/03bis-install-shlink-fullchain.sh"
        traefik_shlink_fullchain_cert_automatically_updated=true;
    fi

    # Ensure shlink fullchain file exists
    if [[ ! -f "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}" ]]; then 
        "${HELPERS_STACK_HOME}/03bis-install-shlink-fullchain.sh"
        traefik_shlink_fullchain_cert_automatically_updated=true;
    fi

    # Check if traefik shlink fullchain certificate is expired (only if not already updated)
    if [[ -f "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}" ]] && [[ "$traefik_shlink_fullchain_cert_automatically_updated" == "false" ]]; then
        set +e
        "${SIMVA_HOME}/bin/check-certificate-valid.sh" "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE}"
        ret=$?
        set -e
        if [[ $ret != 0 ]]; then
            if [[ "${SIMVA_TLS_GENERATE_SELF_SIGNED}" == "true" ]]; then
                read -p "The traefik shlink fullchain certificate is expired. Do you want to automatically update it ? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
                "$SIMVA_HOME/simva" backup "$CURRENT_STACK";
                "${HELPERS_STACK_HOME}/03bis-install-shlink-fullchain.sh"
                traefik_shlink_fullchain_cert_automatically_updated=true;
            else
                echo "The traefik shlink fullchain certificate is expired. Please update it before starting the stack."
                exit 1
            fi
        fi
    fi

    # Initialize checksum file if needed
    if [[ ! -f "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_SHA256SUMS_FILE}" ]]; then
        set +e
        _check_checksum $SIMVA_TLS_HOME "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_SHA256SUMS_FILE}" "${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILENAME}"
        set -e
    fi
fi