# Script client OIDC client scope to map role 'policy' attribute to a claim


## References

- https://stackoverflow.com/questions/59305895/keycloak-realm-role-attributes-arent-inherited-by-users
- https://lists.jboss.org/pipermail/keycloak-user/2019-February/017122.html
- https://www.keycloak.org/docs/latest/server_installation/#profiles
- https://stackoverflow.com/questions/52518298/how-to-create-a-script-mapper-in-keycloak

- https://www.keycloak.org/docs/latest/server_development/#_script_providers
- https://stackoverflow.com/questions/52518298/how-to-create-a-script-mapper-in-keycloak
- https://github.com/keycloak/keycloak/blob/master/core/src/main/java/org/keycloak/representations/IDToken.java
- https://github.com/keycloak/keycloak/blob/2a4cee60440be6767e0f1e9155cebfa381cfb776/services/src/main/java/org/keycloak/protocol/oidc/mappers/ScriptBasedOIDCProtocolMapper.java#L143
- https://stackoverflow.com/questions/47233720/keycloak-client-protocol-mapper-script-mapper-to-add-request-header-into-token