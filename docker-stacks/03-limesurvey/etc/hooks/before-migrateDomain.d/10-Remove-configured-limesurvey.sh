rm -f "${SIMVA_CONFIG_HOME}/limesurvey/etc/config.php"

# Removing Limesurvey simplesamlphp config data 
cd "${SIMVA_DATA_HOME}/limesurvey${SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH:-/simplesamlphp}-data/config"
rm -rf ./*