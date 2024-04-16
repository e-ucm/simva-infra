rm -rf "${SIMVA_DATA_HOME}/keycloak/deployments/*"´

EXTENSIONS_DIR="${STACK_HOME}/extensions"

# Removing Extension data
EXTENSIONS_DIR="${STACK_HOME}/extensions"
for extension in $(find ${EXTENSIONS_DIR} -mindepth 1 -maxdepth 1 -type d); do
    if [[ -e "${extension}/target" ]]; then
        cd "${extension}/target"
        rm -rf ./*
    fi
done