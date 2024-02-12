###################
# REMOVE SIMVA DATA
###################
# Removing Simva Mongodb data
cd "${SIMVA_DATA_HOME}/simva/mongo"
rm -rf ./*

# Removing Simva API data
cd "${SIMVA_DATA_HOME}/simva/simva-api"
rm -rf ./*

# Removing Simva Front data
cd "${SIMVA_DATA_HOME}/simva/simva-front"
rm -rf ./*

# Removing Simva Trace Allocator data
cd "${SIMVA_DATA_HOME}/simva/simva-trace-allocator"
rm -rf ./*

# Removing Simva Trace Allocator logs
if [[ -e "${SIMVA_PROJECT_DIR}/trace-allocator.log" ]]; then
    rm "${SIMVA_PROJECT_DIR}/trace-allocator.log"
fi