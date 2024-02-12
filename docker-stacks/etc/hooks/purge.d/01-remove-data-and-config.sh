#############
# REMOVE DATA
#############
# Removing wait-for file
if [[ -e "${SIMVA_CONTAINER_TOOLS_HOME}/wait-for" ]]; then
    rm "${SIMVA_CONTAINER_TOOLS_HOME}/wait-for"
fi

# Removing gomplate file
if [[ -e "${SIMVA_PROJECT_DIR}/bin/gomplate" ]]; then
    rm "${SIMVA_PROJECT_DIR}/bin/gomplate"
fi

# Removing .simva-initialized file
if [[ -e "${SIMVA_PROJECT_DIR}/.simva-initialized" ]]; then
    rm "${SIMVA_PROJECT_DIR}/.simva-initialized"
fi

# Removing .vagrant file
if [[ -e "${SIMVA_PROJECT_DIR}/.vagrant" ]]; then
    rm "${SIMVA_PROJECT_DIR}/.vagrant"
fi