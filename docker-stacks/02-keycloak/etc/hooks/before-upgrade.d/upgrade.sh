if [[ ${SIMVA_KEYCLOAK_VERSION:0:2} -gt 18 ]]; then
    exit 0
fi
touch "${SIMVA_CONFIG_HOME}/keycloak/simva-realm-export/.exportinprogress"
echo "$SIMVA_KEYCLOAK_VERSION" > "${SIMVA_CONFIG_HOME}/keycloak/.migration"