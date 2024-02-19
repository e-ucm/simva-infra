#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
__file_env() {
    local save_bash_options=$-
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    set +u
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    set -u
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"

    if [[ $save_bash_options =~ u ]]; then
        set -u
    fi
}

# #################################
# ### DISABLED DUPLICATED CODE  ###
# #################################
# if [[ ! -e "${SIMVA_TLS_HOME}/limesurvey.pem" ]]; then
#     openssl genrsa -out ${SIMVA_TLS_HOME}/limesurvey-key.pem 2048
#     openssl req \
#         -subj "${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT_SUBJ}" \
#         -new -key ${SIMVA_TLS_HOME}/limesurvey-key.pem \
#         -out ${SIMVA_TLS_HOME}/limesurvey.csr
# 
#     export CAROOT=${SIMVA_TLS_HOME}
#     mkcert \
#         -cert-file ${SIMVA_TLS_HOME}/limesurvey.pem \
#         -csr ${SIMVA_TLS_HOME}/limesurvey.csr
# 
#     cp ${SIMVA_TLS_HOME}/limesurvey.pem ${SIMVA_TLS_HOME}/limesurvey-fullchain.pem
#     cat ${SIMVA_TLS_HOME}/rootCA.pem >> ${SIMVA_TLS_HOME}/limesurvey-fullchain.pem
# fi
# #################################

# Oneline certificate
limesurvey_cert=$(cat "${SIMVA_TLS_HOME}/limesurvey.pem" | tail -n +2 | head -n -1 | sed ':a;N;$!ba;s/\n//g')
limesurvey_privatekey=$(cat "${SIMVA_TLS_HOME}/limesurvey-key.pem" | tail -n +2 | head -n -1 | sed ':a;N;$!ba;s/\n//g')

function configure_realm_production() {
    generate_realm_data "${STACK_CONF}/realm-data.prod.yml"
    configure_realm_dir "prod"
    configure_realm_file "prod"
}

function generate_realm_data() {
    if [[  $# -lt 1 ]]; then
        echo >&2 "missing destination path";
        exit 1;
    fi
    local conf_file="${1}"

    if [[ -e "${conf_file}" ]]; then
        echo "Config file already available: ${conf_file}";
        return
    fi

    if [[ ! -e "${STACK_CONF}/simva-env.sh" ]]; then
        touch "${STACK_CONF}/simva-env.sh"
    fi

    echo "---" > ${conf_file}
    echo "users:" >> ${conf_file}

    # Update users config
    users="student teaching_assistant teacher researcher administrator"
    for user in $users; do
        user=$(echo ${user} | sed -e 's/[^0-9A-Za-z_]/_/g' )
        user_username=$(get_or_generate_username "${user}" "${STACK_CONF}/simva-env.sh")
        user_password=$(get_or_generate_password "${user}" "${STACK_CONF}/simva-env.sh")

        secretData=""
        while read l; do
            credentialData=$secretData;
            secretData=$l;
        done < <(${SIMVA_HOME}/bin/pbkdf2 -b64 -l 64 -i 27500 -j ${user_password})
        secretData=$(echo ${secretData} | sed -e 's/"/\\\\\\"/g')
        credentialData=$(echo ${credentialData} | sed -e 's/"/\\\\\\"/g')
        echo "  ${user}:" >> ${conf_file}
        echo "    username: \"${user_username}\"" >> ${conf_file}
        echo "    password: \"${user_password}\"" >> ${conf_file}
        echo "    secretData: \"${secretData}\"" >> ${conf_file}
        echo "    credentialData: \"${credentialData}\"" >> ${conf_file}
    done

    echo "clients:" >> ${conf_file}
    client_id=$(get_or_generate_username "limesurvey_admin" "${STACK_CONF}/simva-env.sh")
    client_secret=$(get_or_generate_password "limesurvey_admin" "${STACK_CONF}/simva-env.sh")

    echo "  limesurvey:" >> ${conf_file}
    echo "    baseUrl: \"https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN:-limesurvey}.${SIMVA_EXTERNAL_DOMAIN}\"" >> ${conf_file}
    echo "    sspBaseUrl: \"https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN:-limesurvey}.${SIMVA_EXTERNAL_DOMAIN}${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH}/module.php/saml/sp\"" >> ${conf_file}
    echo "    clientId: \"${client_id}\"" >> ${conf_file}
    echo "    secret: \"${client_secret}\"" >> ${conf_file}
    echo "    certificate: \"${limesurvey_cert}\"" >> ${conf_file}

    client_id=$(get_or_generate_username "minio" "${STACK_CONF}/simva-env.sh")
    client_secret=$(get_or_generate_password "minio" "${STACK_CONF}/simva-env.sh")

    echo "  minio:" >> ${conf_file}
    echo "    baseUrl: \"https://${SIMVA_MINIO_HOST_SUBDOMAIN:-minio}.${SIMVA_EXTERNAL_DOMAIN}\"" >> ${conf_file}
    echo "    clientId: \"${client_id}\"" >> ${conf_file}
    echo "    secret: \"${client_secret}\"" >> ${conf_file}

    client_id=$(get_or_generate_username "simva" "${STACK_CONF}/simva-env.sh")
    client_secret=$(get_or_generate_password "simva" "${STACK_CONF}/simva-env.sh")

    echo "  simva:" >> ${conf_file}
    echo "    externalDomain: \"${SIMVA_EXTERNAL_DOMAIN}\"" >> ${conf_file}
    echo "    baseUrl: \"https://${SIMVA_EXTERNAL_DOMAIN}\"" >> ${conf_file}
    echo "    apiUrl: \"https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN:-simva-api}.${SIMVA_EXTERNAL_DOMAIN}\"" >> ${conf_file}
    echo "    ssoUrl: \"https://${SIMVA_SSO_HOST_SUBDOMAIN:-sso}.${SIMVA_EXTERNAL_DOMAIN}\"" >> ${conf_file}    
    echo "    realmId: \"${SIMVA_SSO_REALM}\"" >> ${conf_file}
    echo "    clientId: \"${client_id}\"" >> ${conf_file}
    echo "    secret: \"${client_secret}\"" >> ${conf_file}
    
    client_id=$(get_or_generate_username "lti_platform" "${STACK_CONF}/simva-env.sh")
    client_secret=$(get_or_generate_password "lti_platform" "${STACK_CONF}/simva-env.sh")

    echo "  lti_platform:" >> ${conf_file}
    echo "    clientId: \"${client_id}\"" >> ${conf_file}
    echo "    secret: \"${client_secret}\"" >> ${conf_file}

    client_id=$(get_or_generate_username "lti_tool" "${STACK_CONF}/simva-env.sh")
    client_secret=$(get_or_generate_password "lti_tool" "${STACK_CONF}/simva-env.sh")

    echo "  lti_tool:" >> ${conf_file}
    echo "    clientId: \"${client_id}\"" >> ${conf_file}
    echo "    secret: \"${client_secret}\"" >> ${conf_file}

}

function get_or_generate_password() {
    local client=${1}
    local conf=${2:-""}

    local var="SIMVA_${client^^}_PASSWORD"
    var=$(echo $var | sed -e 's/[^0-9A-Za-z_]/_/g' )

    __file_env $var ''

    if [[ -z "${!var}" ]]; then
        client_secret=$((cat /dev/urandom || true) | (tr -c -d '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' || true ) | dd bs=32 count=1 2>/dev/null)
        if [[ -e ${conf} ]]; then
            echo "export ${var}=\"${client_secret}\"" >> "${conf}"
        fi
    else
        client_secret=${!var}
    fi

    echo ${client_secret}
}

function get_or_generate_username() {
    local client=${1}
    local conf=${2:-""}

    local var="SIMVA_${client^^}_USER"
    var=$(echo $var | sed -e 's/[^0-9A-Za-z_]/_/g' )

    __file_env $var ''

    if [[ -z "${!var}" ]]; then
        client_user=${client}
        if [[ -e ${conf} ]]; then
            echo "export ${var}=\"${client_user}\"" >> "${conf}"
        fi
    else
        client_user=${!var}
    fi

    echo ${client_user}
}


function configure_realm_dir() {
    if [[  $# -lt 1 ]]; then
        echo >&2 "missing environment";
        exit 1;
    fi

    local environment="${1}"

    gomplate -c ".=file://${STACK_CONF}/realm-data.${environment}.yml" \
        -f "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-template/simva-realm.json" \
        -o "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/simva-realm.json"

    gomplate -c ".=file://${STACK_CONF}/realm-data.${environment}.yml" \
        -f "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-template/simva-users-0.json" \
        -o "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/simva-users-0.json"

}

function configure_realm_file() {
    if [[  $# -lt 1 ]]; then
        echo >&2 "missing environment";
        exit 1;
    fi

    local environment="${1}"

    gomplate -c ".=file://${STACK_CONF}/realm-data.${environment}.yml" \
        -f "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-template/simva-realm-full.json" \
        -o "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/simva-realm-full.json"

}

function configure_realm_development() {
    generate_realm_data "${STACK_CONF}/realm-data.dev.yml"
    configure_realm_dir "dev"
    configure_realm_file "dev"
}

configure_realm_${SIMVA_ENVIRONMENT}
