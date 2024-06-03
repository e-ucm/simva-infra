##########################
# REMOVE LIMESURVEY CONFIG
##########################
# Removing Limesurvey etc config 
cd "${SIMVA_CONFIG_HOME}/limesurvey/etc" && rm -rf ./*

########################
# REMOVE LIMESURVEY DATA
########################
# Removing Limesurvey etc data 
cd "${SIMVA_DATA_HOME}/limesurvey/data/etc" && rm -rf ./*

# Removing Limesurvey plugins data 
cd "${SIMVA_DATA_HOME}/limesurvey/data/plugins" && rm -rf ./*

# Removing Limesurvey tmp data 
cd "${SIMVA_DATA_HOME}/limesurvey/data/tmp" && rm -rf ./*

# Removing Limesurvey upload data 
cd "${SIMVA_DATA_HOME}/limesurvey/data/upload" && rm -rf ./*

# Removing Limesurvey mariadb data 
cd "${SIMVA_DATA_HOME}/limesurvey/mariadb" && rm -rf ./*

# Removing Limesurvey mariadb dump data 
cd "${SIMVA_DATA_HOME}/limesurvey/mariadb-dump" && rm -rf ./*

# Removing Limesurvey simplesamlphp config data 
cd "${SIMVA_DATA_HOME}/limesurvey${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH:-/simplesamlphp}-data/config" && rm -rf ./*

if [[ -e "${SIMVA_DATA_HOME}/limesurvey/.initialized" ]]; then
    rm "${SIMVA_DATA_HOME}/limesurvey/.initialized"
fi
if [[ -e "${SIMVA_DATA_HOME}/limesurvey/.externaldomain" ]]; then
    rm "${SIMVA_DATA_HOME}/limesurvey/.externaldomain"
fi 
if [[ -e "${SIMVA_DATA_HOME}/limesurvey/.version" ]]; then
    rm "${SIMVA_DATA_HOME}/limesurvey/.version"
fi