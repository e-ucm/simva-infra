# Removing Keycloak Mariadb data
cd "${SIMVA_DATA_HOME}/keycloak/mariadb"
rm -rf ./*

# Removing Keycloak Mariadb dump data
cd "${SIMVA_DATA_HOME}/keycloak/mariadb-dump"
rm -rf ./*