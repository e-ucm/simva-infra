######################
# REMOVE KEYCLOAK DATA
######################
# Removing Keycloak deployments data
cd "${SIMVA_DATA_HOME}/keycloak/deployments"
(GLOBIGNORE=README.txt ; rm -rf *)

# Removing Keycloak kcadm data
cd "${SIMVA_DATA_HOME}/keycloak/kcadm"
rm -rf ./*

# Removing Keycloak Mariadb data
cd "${SIMVA_DATA_HOME}/keycloak/mariadb"
rm -rf ./*

# Removing Keycloak Mariadb dump data
cd "${SIMVA_DATA_HOME}/keycloak/mariadb-dump"
rm -rf ./*

# Removing Maven data
cd "${SIMVA_DATA_HOME}/maven/m2"
rm -rf ./*

###############################
# REMOVE KEYCLOAK CONFIGURATION
###############################
# Removing Simva Theme properties Account page 
if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/themes/simva/account/theme.properties" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/themes/simva/account/theme.properties"
fi

# Removing Keycloak Simva Realm Configuration
cd "${SIMVA_CONFIG_HOME}/keycloak/simva-realm"
rm -rf ./*

# Removing Keycloak Simva Realm backups Configuration
cd "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export"
rm -rf ./*

# Removing Keycloak simva-env.sh configuration file
if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/simva-env.sh"
fi

# Removing Keycloak realm-data.dev.yml configuration file
if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml"
fi

# Removing Keycloak realm-data.prod.yml configuration file
if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml"
fi

rm "${STACK_HOME}/.initialized"