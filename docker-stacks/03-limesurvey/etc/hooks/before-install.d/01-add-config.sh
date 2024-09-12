#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

config_contents=$(<"${SIMVA_CONFIG_HOME}/limesurvey/etc-template/config.php")

# Ensure security.php can be created
touch "${SIMVA_CONFIG_HOME}/limesurvey/etc/security.php"

echo "${config_contents}" \
    | sed  "s/<<SIMVA_LIMESURVEY_MYSQL_DATABASE>>/${SIMVA_LIMESURVEY_MYSQL_DATABASE}/g" \
    | sed  "s/<<SIMVA_INTERNAL_DOMAIN>>/${SIMVA_INTERNAL_DOMAIN}/g" \
    | sed  "s/<<SIMVA_LIMESURVEY_MYSQL_USER>>/${SIMVA_LIMESURVEY_MYSQL_USER}/g" \
    | sed  "s/<<SIMVA_LIMESURVEY_MYSQL_PASSWORD>>/${SIMVA_LIMESURVEY_MYSQL_PASSWORD}/g" \
    | sed  "s/<<SIMVA_LIMESURVEY_HOST_SUBDOMAIN>>/${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}/g" \
    > "${SIMVA_CONFIG_HOME}/limesurvey/etc/config.php"
chmod -R 755 "${SIMVA_CONFIG_HOME}/limesurvey/etc/"
chown -R 33:33 "${SIMVA_CONFIG_HOME}/limesurvey/etc/"

