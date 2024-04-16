# Removing Limesurvey generated certificates 
#rm "${SIMVA_TLS_HOME}/limesurvey.pem"
#rm "${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY:-limesurvey-key.pem}"
#rm "${SIMVA_TLS_HOME}/limesurvey.csr"
rm "${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT:-limesurvey-fullchain.pem}"

# Removing configured protocol mapper
$LTI13OIDCProtocolMapperFile= "${STACK_HOME}/extensions/simva-lti/src/main/java/es/eucm/keycloak/lti13/LTI13OIDCProtocolMapper.java"
if [[ -e $LTI13OIDCProtocolMapperFile ]]; then 
    rm $LTI13OIDCProtocolMapperFile 
fi

# Removing Simva Theme properties Account page 
if [[ -e "${SIMVA_CONFIG_HOME}/keycloak/themes/simva/account/theme.properties" ]]; then
    rm "${SIMVA_CONFIG_HOME}/keycloak/themes/simva/account/theme.properties"
fi