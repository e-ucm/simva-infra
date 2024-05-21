###################
# REMOVE SIMVA DATA
###################
# Removing Simva Mongodb data
cd "${SIMVA_DATA_HOME}/simva/mongo" && rm -rf ./*

# RemovingSimva Puppeteer data 
cd "${SIMVA_DATA_HOME}/simva/puppeteer" && rm -rf ./*

# Removing Simva API data
cd "${SIMVA_DATA_HOME}/simva/simva-api" && rm -rf ./*

# Removing Simva Front data
cd "${SIMVA_DATA_HOME}/simva/simva-front" && rm -rf ./*

# Removing Simva Trace Allocator data
cd "${SIMVA_DATA_HOME}/simva/simva-trace-allocator" && rm -rf ./*

# Removing Simva Trace Allocator logs
if [[ -e "${SIMVA_PROJECT_DIR}/trace-allocator.log" ]]; then
    rm "${SIMVA_PROJECT_DIR}/trace-allocator.log"
fi

if [[ -e "${STACK_HOME}/.initialized" ]]; then
    rm "${STACK_HOME}/.initialized"
fi
if [[ -e "${STACK_HOME}/.externaldomain" ]]; then
    rm "${STACK_HOME}/.externaldomain"
fi 
if [[ -e "${STACK_HOME}/.version" ]]; then
    rm "${STACK_HOME}/.version"
fi