file_input = $(cat ${SIMVA_CONFIG_HOME}/limesurvey/config.php)
newstr=$(
    echo "${file_input}  
    | sed  's/<<SIMVA_LIMESURVEY_MYSQL_DATABASE>>/$(SIMVA_LIMESURVEY_MYSQL_DATABASE)/g'
    | sed  's/<<SIMVA_INTERNAL_DOMAIN>>/$(SIMVA_INTERNAL_DOMAIN)/g'
    | sed  's/<<SIMVA_LIMESURVEY_MYSQL_USER>>/$(SIMVA_LIMESURVEY_MYSQL_USER)/g'
    | sed  's/<<SIMVA_LIMESURVEY_MYSQL_PASSWORD>>/$(SIMVA_LIMESURVEY_MYSQL_PASSWORD)/g'
)
echo newstr > ${SIMVA_DATA_HOME}/limesurvey/data/etc/config.php 