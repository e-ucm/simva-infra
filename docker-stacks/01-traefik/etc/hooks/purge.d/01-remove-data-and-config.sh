##############################
# REMOVE TRAEFIK CONFIGURATION
##############################
# Removing Traefik Static Conf
cd "${SIMVA_CONFIG_HOME}/traefik/traefik/static-conf" && rm -rf ./*

# Removing all certificates
cd "${SIMVA_TLS_HOME}" && rm -rf ./*

#####################
# REMOVE TRAEFIK DATA
#####################
# Removing Traefik CSP Reporter data
rm -rf "${SIMVA_DATA_HOME}/traefik/csp-reporter"

if [[ -e "${SIMVA_DATA_HOME}/traefik/.initialized" ]]; then
    rm "${SIMVA_DATA_HOME}/traefik/.initialized"
fi
if [[ -e "${SIMVA_DATA_HOME}/traefik/.externaldomain" ]]; then
    rm "${SIMVA_DATA_HOME}/traefik/.externaldomain"
fi 
if [[ -e "${SIMVA_DATA_HOME}/traefik/.version" ]]; then
    rm "${SIMVA_DATA_HOME}/traefik/.version"
fi