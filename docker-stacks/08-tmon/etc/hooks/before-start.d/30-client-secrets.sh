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
    > "${tmon_folder}/${base_name}${base_extension}"