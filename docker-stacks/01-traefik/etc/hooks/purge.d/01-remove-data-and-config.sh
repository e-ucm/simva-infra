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

if [[ -e "${STACK_HOME}/.initialized" ]]; then
    rm "${STACK_HOME}/.initialized"
fi
if [[ -e "${STACK_HOME}/.externaldomain" ]]; then
    rm "${STACK_HOME}/.externaldomain"
fi 
if [[ -e "${STACK_HOME}/.version" ]]; then
    rm "${STACK_HOME}/.version"
fi