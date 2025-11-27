#!/bin/bash

# Copy config.php if present in external volume
if [ -f /custom-config/config.php ]; then
    echo "[INFO] Using external config.php"
    cp /custom-config/config.php /var/www/html/application/config/config.php
fi

# Copy security.php if present in external volume
if [ -f /custom-config/security.php ]; then
    echo "[INFO] Using external security.php"
    cp /custom-config/security.php /var/www/html/application/config/security.php
fi

# Continue with LimeSurvey original entrypoint
/container-tools/wait-for-it.sh -h ${DB_HOST} -p 3306 -t ${WAIT_TIMEOUT}
exec /usr/local/bin/entrypoint.sh $@