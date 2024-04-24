# Check if the container is running
if $(docker ps --format '{{.Names}}' | grep "keycloak-1"); then
    echo "Keycloak container is running. Launching export of users..."
    if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 18 ]]; then 
        rm -rf ${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/keycloak/simva-realm-export/*
        docker compose exec keycloak /opt/keycloak/bin/kc.sh export --dir "/opt/keycloak/data/export/" --users different_files --users-per-file 100 --realm ${SIMVA_SSO_REALM:-simva} --optimized
    else 
        #if [[ ${SIMVA_KEYCLOAK_VERSION%%.*} > 13 ]]; then
        #    docker exec $container_name /opt/jboss/tools/docker-entrypoint.sh -Dkeycloak.migration.action=export -Dkeycloak.migration.provider=dir -Dkeycloak.migration.dir=/var/tmp/simva-realm -Dkeycloak.migration.usersExportStrategy=SAME_FILE
        #fi
        echo "Please upgrade to a newer keycloak version ( > 18.*.*) before exporting users and realm."
    fi;   
else
    echo "Keycloak container is not running."
fi
