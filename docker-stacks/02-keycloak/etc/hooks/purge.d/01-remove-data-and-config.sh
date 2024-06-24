${SIMVA_HOME}/bin/purge-folder-contents.sh \
    "${SIMVA_DATA_HOME}/keycloak/deployments" \
    "${SIMVA_DATA_HOME}/keycloak/kcadm" \
    "${SIMVA_DATA_HOME}/keycloak/mariadb" \
    "${SIMVA_DATA_HOME}/keycloak/mariadb-dump" \
    "${SIMVA_DATA_HOME}/maven/m2" \
    "${SIMVA_CONFIG_HOME}/keycloak/simva-realm" \
    "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export"

${SIMVA_HOME}/bin/purge-file-if-exist.sh \
    "${SIMVA_CONFIG_HOME}/keycloak/themes/simva/account/theme.properties" \
    "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh" \
    "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml" \
    "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml" \
    "${SIMVA_CONFIG_HOME}/keycloak/realm-data.users.yml" \
    "${SIMVA_DATA_HOME}/keycloak/.initialized" \
    "${SIMVA_DATA_HOME}/keycloak/.externaldomain" \
    "${SIMVA_DATA_HOME}/keycloak/.version"