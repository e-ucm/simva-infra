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

if [[ ! -e "${SIMVA_TLS_HOME}/limesurvey.pem" ]]; then
    openssl genrsa -out ${SIMVA_TLS_HOME}/limesurvey-key.pem 2048
    openssl req \
        -subj "${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT_SUBJ}" \
        -new -key ${SIMVA_TLS_HOME}/limesurvey-key.pem \
        -out ${SIMVA_TLS_HOME}/limesurvey.csr

    export CAROOT=${SIMVA_TLS_HOME}
    mkcert \
        -cert-file ${SIMVA_TLS_HOME}/limesurvey.pem \
        -csr ${SIMVA_TLS_HOME}/limesurvey.csr

    cp ${SIMVA_TLS_HOME}/limesurvey.pem ${SIMVA_TLS_HOME}/limesurvey-fullchain.pem
    cat ${SIMVA_TLS_HOME}/rootCA.pem >> ${SIMVA_TLS_HOME}/limesurvey-fullchain.pem
fi

# Oneline certificate
limesurvey_cert=$(cat "${SIMVA_TLS_HOME}/limesurvey.pem" | tail -n +2 | head -n -1 | sed ':a;N;$!ba;s/\n//g')

function configure_realm_production() {
    configure_realm_dir_production
    configure_realm_file_production
}

function configure_realm_dir_production() {

# Update certificate in realm config
jq_script=$(cat <<'JQ_SCRIPT'
def when(c; f): if c? // null then f else . end;
.clients = (
  .clients
    | map( when( .clientId==$clientId; .attributes["saml.signing.certificate"] = $newCertificate) )
      | map( when( .clientId==$clientId; .attributes["saml.encryption.certificate"] = $newCertificate) )
)
JQ_SCRIPT
)

cat ${SIMVA_CONFIG_HOME}/keycloak/simva-realm-template/simva-realm.json | jq \
  --arg clientId "https://limesurvey.external.test/simplesamlphp/module.php/saml/sp/metadata.php/https___sso_external_test_auth_realms_simva" \
  --arg newCertificate "${limesurvey_cert}" \
  "$jq_script" > "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/simva-realm.json"

# Update users config
users="student teaching-assistant teacher researcher administrator"
tmp_file="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-template/simva-users-0.json"
for user in $users; do
    users_file=$tmp_file
    tmp_file=$(mktemp)

    var="SIMVA_${user^^}_PASSWORD"
    var=$(echo $var | sed -e 's/[^0-9A-Za-z_]/_/g' )
    __file_env $var ''
    if [[ -z "${!var}" ]]; then
        user_password=$((cat /dev/urandom || true) | (tr -c -d '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' || true ) | dd bs=32 count=1 2>/dev/null)
        echo "export ${var}=\"${user_password}\"" >> "${SIMVA_HOME}/bin/simva-users-passwords.sh"
    else
        user_password=${!var}
    fi

    secretData=""
    while read l; do
        credentialData=$secretData;
        secretData=$l;
    done < <(${SIMVA_HOME}/bin/pbkdf2 -b64 -l 64 -i 27500 -j ${user_password} | sed -e 's/"/\\"/g')

    jq_script=$(cat <<'JQ_SCRIPT'
def when(c; f): if c? // null then f else . end;
.users = (
    .users
        | map( when( .username==$username; .credentials[0].secretData = $secretData) )
            | map( when( .username==$username; .credentials[0].credentialData = $credentialData) )
)
JQ_SCRIPT
)
    cat "${users_file}" | jq \
        --arg username "${user}" \
        --arg secretData "${secretData}" \
        --arg credentialData "${credentialData}" \
        "$jq_script" > $tmp_file
done

cp $tmp_file "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/simva-users-0.json"

}

function configure_realm_file_production() {

# Update certificate in realm config
jq_script=$(cat <<'JQ_SCRIPT'
def when(c; f): if c? // null then f else . end;
.clients = (
  .clients
    | map( when( .clientId==$clientId; .attributes["saml.signing.certificate"] = $newCertificate) )
      | map( when( .clientId==$clientId; .attributes["saml.encryption.certificate"] = $newCertificate) )
)
JQ_SCRIPT
)

# XXX pending parameter for keycloak client Id
cat ${SIMVA_CONFIG_HOME}/keycloak/simva-realm-template/simva-realm-full.json | jq \
  --arg clientId "https://limesurvey.external.test/simplesamlphp/module.php/saml/sp/metadata.php/https___sso_external_test_auth_realms_simva" \
  --arg newCertificate "${limesurvey_cert}" \
  "$jq_script" > "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/simva-realm-full.json"

# Update users config
users="student teaching-assistant teacher researcher administrator"
tmp_file="${SIMVA_CONFIG_HOME}/keycloak/simva-realm-template/simva-realm-full.json"
for user in $users; do
    users_file=$tmp_file
    tmp_file=$(mktemp)

    var="SIMVA_${user^^}_PASSWORD"
    var=$(echo $var | sed -e 's/[^0-9A-Za-z_]/_/g' )
    __file_env $var ''
    if [[ -z "${!var}" ]]; then
        user_password=$((cat /dev/urandom || true) | (tr -c -d '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' || true ) | dd bs=32 count=1 2>/dev/null)
        echo "export ${var}=\"${user_password}\"" >> "${SIMVA_HOME}/bin/simva-users-passwords.sh"
    else
        user_password=${!var}
    fi

    secretData=""
    while read l; do
        credentialData=$secretData;
        secretData=$l;
    done < <(${SIMVA_HOME}/bin/pbkdf2 -b64 -l 64 -i 27500 -j ${user_password} | sed -e 's/"/\\"/g')

    jq_script=$(cat <<'JQ_SCRIPT'
def when(c; f): if c? // null then f else . end;
.users = (
    .users
        | map( when( .username==$username; .credentials[0].secretData = $secretData) )
            | map( when( .username==$username; .credentials[0].credentialData = $credentialData) )
)
JQ_SCRIPT
)
    cat "${users_file}" | jq \
        --arg username "${user}" \
        --arg secretData "${secretData}" \
        --arg credentialData "${credentialData}" \
        "$jq_script" > $tmp_file
done

cp $tmp_file "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/simva-realm-full.json"

}

function configure_realm_development() {
    cp ${SIMVA_CONFIG_HOME}/keycloak/simva-realm-template/* ${SIMVA_CONFIG_HOME}/keycloak/simva-realm
}

configure_realm_${SIMVA_ENVIRONMENT}