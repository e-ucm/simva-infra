########################
# REMOVE LIMESURVEY DATA
########################
# Removing Limesurvey etc data 
cd "${SIMVA_DATA_HOME}/limesurvey/data/etc" && rm -rf ./*

# Removing Limesurvey plugins data 
cd "${SIMVA_DATA_HOME}/limesurvey/data/plugins" && rm -rf ./*

# Removing Limesurvey tmp data 
cd "${SIMVA_DATA_HOME}/limesurvey/data/tmp" && rm -rf ./*