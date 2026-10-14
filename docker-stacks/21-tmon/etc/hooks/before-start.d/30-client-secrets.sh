#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

tmon_config_folder="${SIMVA_CONFIG_TEMPLATE_HOME}/tmon"
tmon_folder="${SIMVA_TMON_GIT_REPO}"
base_name="client_secrets"
base_extension=".json"
cat "${tmon_config_folder}/${base_name}${base_extension}" \
    | sed  "s/<<SIMVA_TMON_DASHBOARD_HOST_SUBDOMAIN>>/${SIMVA_TMON_DASHBOARD_HOST_SUBDOMAIN}/g" \
    | sed  "s/<<SIMVA_EXTERNAL_DOMAIN>>/${SIMVA_EXTERNAL_DOMAIN}/g" \
    | sed  "s/<<SIMVA_SSO_HOST_SUBDOMAIN>>/${SIMVA_SSO_HOST_SUBDOMAIN}/g" \
    | sed  "s/<<SIMVA_SSO_REALM>>/${SIMVA_SSO_REALM}/g" \
    | sed  "s/<<SIMVA_TMON_CLIENT_ID>>/${SIMVA_TMON_CLIENT_ID}/g" \
    | sed  "s/<<SIMVA_TMON_CLIENT_SECRET>>/${SIMVA_TMON_CLIENT_SECRET}/g" \
    | sed  "s/<<SIMVA_SIMVA_API_HOST_SUBDOMAIN>>/${SIMVA_SIMVA_API_HOST_SUBDOMAIN}/g" \
    | sed  "s/<<SSL_CERT_FILE>>/\/root\/.tmon\/certs\/ca\/${SIMVA_ROOT_CA_FILENAME}/g" \
    | sed  "s/<<SIMVA_LRS_HOST_SUBDOMAIN>>/${SIMVA_LRS_HOST_SUBDOMAIN}/g" \
    | sed  "s/<<SIMVA_LRS_USERNAME>>/${SIMVA_LRS_API_KEY_DEFAULT}/g" \
    | sed  "s/<<SIMVA_LRS_PASSWORD>>/${SIMVA_LRS_API_SECRET_DEFAULT}/g" \
    | sed  "s/<<SIMVA_LRS_LAG_SECONDS>>/${SIMVA_TMON_LRS_LAG_SECONDS}/g" \
    > "${tmon_folder}/${base_name}${base_extension}"