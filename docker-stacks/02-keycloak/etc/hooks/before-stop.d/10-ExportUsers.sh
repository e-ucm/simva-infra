if [[ $(echo ${SIMVA_KEYCLOAK_VERSION%%.*}) > 18 ]]; then 
    docker exec -it 02-keycloak-keycloak-1 /opt/keycloak/bin/kc.sh export --dir "/opt/keycloak/data/export/" --users same_file --realm ${SIMVA_SSO_REALM:-simva} --optimized
fi;