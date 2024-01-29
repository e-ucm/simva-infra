cd "${SIMVA_DATA_HOME}/keycloak/deployments"
rm -rf ./*

cd "${SIMVA_DATA_HOME}/keycloak/kcadm"
rm -rf ./*

cd "${SIMVA_DATA_HOME}/keycloak/mariadb"
rm -rf ./*

cd "${SIMVA_DATA_HOME}/keycloak/mariadb-dump"
rm -rf ./*

cd "${SIMVA_CONFIG_HOME}/keycloak/simva-realm"
rm -rf ./*

if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh"
fi

if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml"
fi

if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml"
fi
