#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source ${SIMVA_BIN_HOME}/get-or-generate.sh

# Oneline certificate
limesurvey_cert=$(sed '1d; $d;:a;N;$!ba;s/\n//g' "${SIMVA_LIMESURVEY_CERT_FILE}")

function configure_realm_production() {
    generate_realm_data "${STACK_CONF}/realm-data.prod.yml"
    configure_realm_file "prod"
}

function generate_realm_data() {
    if [[  $# -lt 1 ]]; then
        echo >&2 "missing destination path";
        exit 1;
    fi
    local conf_file="${1}"

    if [[ -e "${conf_file}" ]]; then
        echo "A config file available: ${conf_file}. Regenerating it again for any new changes...";
        rm -rf ${conf_file};
    fi

    if [[ ! -e "${STACK_CONF}/simva-env.sh" ]]; then
        touch "${STACK_CONF}/simva-env.sh"
    fi
    
    events_activated=$([ "$SIMVA_ENVIRONMENT" == "development" ] && echo "true" || echo "false")
    
    limesurvey_client_id=$(get_or_generate_username "limesurvey" "${STACK_CONF}/simva-env.sh")
    limesurvey_client_secret=$(get_or_generate_password "limesurvey" "${STACK_CONF}/simva-env.sh")

    simva_client_id=$(get_or_generate_username "simva" "${STACK_CONF}/simva-env.sh")
    simva_client_secret=$(get_or_generate_password "simva" "${STACK_CONF}/simva-env.sh")

    lti_platform_client_id=$(get_or_generate_username "lti_platform" "${STACK_CONF}/simva-env.sh")
    lti_platform_client_secret=$(get_or_generate_password "lti_platform" "${STACK_CONF}/simva-env.sh")

    keycloak_client_client_id=$(get_or_generate_username "keycloak_client" "${STACK_CONF}/simva-env.sh")
    keycloak_client_client_secret=$(get_or_generate_password "keycloak_client" "${STACK_CONF}/simva-env.sh")

    jupyter_client_id=$(get_or_generate_username "jupyter" "${STACK_CONF}/simva-env.sh")
    jupyter_client_secret=$(get_or_generate_password "jupyter" "${STACK_CONF}/simva-env.sh")

    tmon_client_id=$(get_or_generate_username "tmon" "${STACK_CONF}/simva-env.sh")
    tmon_client_secret=$(get_or_generate_password "tmon" "${STACK_CONF}/simva-env.sh")

    pumva_client_id=$(get_or_generate_username "pumva" "${STACK_CONF}/simva-env.sh")
    pumva_client_secret=$(get_or_generate_password "pumva" "${STACK_CONF}/simva-env.sh")

cat << EOF > ${conf_file}
smtpServer:
  host: "${SIMVA_MAIL_HOST_SUBDOMAIN}.${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}"
  port: "${SIMVA_MAIL_PORT}"
  fromDisplayName: "${SIMVA_SSO_HOST_SUBDOMAIN} ${SIMVA_SSO_REALM}"
  from: "${SIMVA_MAIL_FROM_USERNAME}@${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
  replyToDisplayName: "${SIMVA_SSO_HOST_SUBDOMAIN} ${SIMVA_SSO_REALM}"
  replyTo: "${SIMVA_MAIL_REPLYTO_USERNAME}@${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
  envelopeFrom: "${SIMVA_MAIL_FROM_USERNAME}@${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
  ssl: "${SIMVA_MAIL_SSL}"
  starttls: "${SIMVA_MAIL_STARTTLS}"
  auth: "${SIMVA_MAIL_AUTH}"
  user: "${SIMVA_MAIL_USER}"
  password: "${SIMVA_MAIL_PASSWORD}"
events: 
  enabled: "${events_activated}"
clients:
  limesurvey:
    baseUrl: "https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
    sspBaseUrl: "https://${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH}/module.php/saml/sp"
    clientId: "${limesurvey_client_id}"
    secret: "${limesurvey_client_secret}"
    certificate: "${limesurvey_cert//-----END CERTIFICATE-----/}"
  simva:
    externalDomain: "${SIMVA_EXTERNAL_DOMAIN}"
    baseUrl: "https://${SIMVA_EXTERNAL_DOMAIN}"
    apiUrl: "https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
    ssoUrl: "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
    realmId: "${SIMVA_SSO_REALM}"
    clientId: "${simva_client_id}"
    secret: "${simva_client_secret}"
    registrationAllowed: "${SIMVA_SSO_SELF_REGISTRATION_ALLOWED}"
  lti_platform:
    baseUrl: "https://${SIMVA_EXTERNAL_DOMAIN}"
    clientId: "${lti_platform_client_id}"
    secret: "${lti_platform_client_secret}"
  keycloak_client:
    clientId: "${keycloak_client_client_id}"
    secret: "${keycloak_client_client_secret}"
  jupyter:
    clientId: "${jupyter_client_id}"
    secret: "${jupyter_client_secret}"
    baseUrl: "https://${SIMVA_JUPYTER_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/tree"
  tmon:
    clientId: "${tmon_client_id}"
    secret: "${tmon_client_secret}"
    baseUrl: "https://${SIMVA_TMON_DASHBOARD_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
  pumva:
    clientId: "${pumva_client_id}"
    secret: "${pumva_client_secret}"
    baseUrl: "https://${SIMVA_PUMVA_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
users:
EOF

    users="student teaching_assistant teacher researcher administrator lrsmanager"
    for user in $users; do
        user=$(echo ${user} | sed -e 's/[^0-9A-Za-z_]/_/g' )
        user_username=$(get_or_generate_username "${user}" "${STACK_CONF}/simva-env.sh" "USER")
        cat << EOF >> ${conf_file}
  ${user}:
    username: "${user_username}"
EOF
    done
}

function configure_realm_file() {
    if [[  $# -lt 1 ]]; then
        echo >&2 "missing environment";
        exit 1;
    fi
    local environment="${1}"
    
    ${SIMVA_BIN_HOME}/purge-folder-contents.sh "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/"

    gomplate -c ".=file://${STACK_CONF}/realm-data.${environment}.yml" \
        -f "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/simva-realm-full.json" \
        -o "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/simva-realm-full.json"

    folders=("clients" "roles" "users")
    for i in "${!folders[@]}"; do
        folder=${folders[$i]};
        if [[ ! -e "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/$folder/" ]]; then 
            mkdir "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/$folder/"
        fi
        for file in ${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/$folder/*; do
            filename=$(basename "$file")
            gomplate -c ".=file://${STACK_CONF}/realm-data.${environment}.yml" \
                    -f "${SIMVA_CONFIG_TEMPLATE_HOME}/keycloak/simva-realm/$folder/${filename}" \
                    -o "${SIMVA_CONFIG_HOME}/keycloak/simva-realm/$folder/${filename}"
        done
    done
}

function configure_realm_development() {
    generate_realm_data "${STACK_CONF}/realm-data.dev.yml"
    configure_realm_file "dev"
}

configure_realm_${SIMVA_ENVIRONMENT}
