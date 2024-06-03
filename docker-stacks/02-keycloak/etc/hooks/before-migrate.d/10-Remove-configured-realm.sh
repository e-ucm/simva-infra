###############################
# REMOVE KEYCLOAK CONFIGURATION
###############################
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

touch "${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/.exportinprogress"