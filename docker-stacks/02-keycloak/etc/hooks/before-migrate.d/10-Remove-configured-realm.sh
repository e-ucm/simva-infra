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

# Removing Keycloak realm-data.dev.yml configuration file
if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/realm-data.dev.yml"
fi

# Removing Keycloak realm-data.prod.yml configuration file
if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/realm-data.prod.yml"
fi