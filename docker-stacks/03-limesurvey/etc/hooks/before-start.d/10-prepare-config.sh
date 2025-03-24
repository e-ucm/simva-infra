#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

source ${SIMVA_HOME}/bin/get-or-generate.sh

function configure_production() {
    generate_data "${STACK_CONF}/data.prod.yml"
    configure_file "prod"
}

function generate_data() {
    if [[  $# -lt 1 ]]; then
        echo >&2 "missing destination path";
        exit 1;
    fi
    local conf_file="${1}"

    if [[ -e "${conf_file}" ]]; then
        echo "A config file available: ${conf_file}. Regenerating it again for any new changes...";
        rm -rf ${conf_file};
    fi

    if [[ ! -e "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh" ]]; then
        touch "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh"
    fi

    limesurvey_client_id=$(get_or_generate_username "limesurvey" "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh")
    limesurvey_client_secret=$(get_or_generate_password "limesurvey" "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh")
    isdev=$([ "$SIMVA_ENVIRONMENT" == "development" ] && echo "true" || echo "false")
    limesurveydebug=$([ $isdev ] && echo 1 || echo 0)

cat << EOF > ${conf_file}
debug: ${limesurveydebug}
db:
  url: "mariadb.${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}"
  database: "${SIMVA_LIMESURVEY_MYSQL_DATABASE}"
  user: "${SIMVA_LIMESURVEY_MYSQL_USER}"
  password: "${SIMVA_LIMESURVEY_MYSQL_PASSWORD}"
plugins:
  webhooks:
    url: "https://${SIMVA_SIMVA_API_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/limesurvey-completion-webhooks"
    api_token: "${SIMVA_LIMESURVEY_WEBHOOK_API_TOKEN}"
    header_name: "${SIMVA_LIMESURVEY_WEBHOOK_HEADER_NAME}"
    header_prefix: "${SIMVA_LIMESURVEY_WEBHOOK_HEADER_PREFIX}"
    debug: "${isdev}"
  oauth2:
    keycloak_realm_url: "https://${SIMVA_SSO_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}/realms/${SIMVA_SSO_REALM}"
    client_id: "${SIMVA_LIMESURVEY_CLIENT_ID}"
    client_secret: "${SIMVA_LIMESURVEY_CLIENT_SECRET}"
    debug: "${isdev}"
EOF
}

function configure_file() {
    if [[  $# -lt 1 ]]; then
        echo >&2 "missing environment";
        exit 1;
    fi
    local environment="${1}"

    gomplate -c ".=file://${STACK_CONF}/data.${environment}.yml" \
        -f "${SIMVA_CONFIG_TEMPLATE_HOME}/limesurvey/etc/config.php" \
        -o "${SIMVA_CONFIG_HOME}/limesurvey/etc/config.php"
}

function configure_development() {
    generate_data "${STACK_CONF}/data.dev.yml"
    configure_file "dev"
}

configure_${SIMVA_ENVIRONMENT}