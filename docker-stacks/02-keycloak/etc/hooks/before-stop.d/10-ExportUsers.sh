if [[ $(echo ${SIMVA_KEYCLOAK_VERSION%%.*}) > 18 ]]; then 
    # Define the name of the Docker container you want to check
    container_name="02-keycloak-keycloak-1"

    # Check if the container is running
    if docker ps --format '{{.Names}}' | grep -q "^$container_name$"; then
        echo "Container '$container_name' is running. Launching export of users..."
        docker exec -it $container_name /opt/keycloak/bin/kc.sh export --dir "/opt/keycloak/data/export/" --users same_file --realm ${SIMVA_SSO_REALM:-simva} --optimized
    else
        echo "Container '$container_name' is not running."
    fi
fi;