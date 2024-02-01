$file_input = cat ${SIMVA_CONFIG_HOME}/limesurvey/config.php 
eval "echo \"$($file_input)\"" > ${SIMVA_DATA_HOME}/limesurvey/data/etc/config.php 