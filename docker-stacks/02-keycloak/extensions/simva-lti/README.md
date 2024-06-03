## References

- https://github.com/tholst/keycloak-json-graphql-remote-claim/
- https://github.com/groupe-sii/keycloak-json-remote-claim/
- https://github.com/mschwartau/keycloak-custom-protocol-mapper-example
- https://github.com/tholst/keycloak-json-graphql-remote-claim
- https://medium.com/@pavithbuddhima/how-to-add-custom-claims-to-jwt-tokens-from-an-external-source-in-keycloak-52bd1ff596d3
- https://medium.com/@gauravwadhone/keycloak-create-custom-rest-api-86e24bff4c1e
- https://github.com/ieggel/DockerRegistryKeycloakUserNamespaceMapper

# Keycloak logging confing

There are two environment variables available to control the log level for Keycloak:

* `KEYCLOAK_LOGLEVEL`: Specify log level for Keycloak (optional, default is `INFO`)
* `ROOT_LOGLEVEL`: Specify log level for underlying container (optional, default is `INFO`)

Supported log levels are `ALL`, `DEBUG`, `ERROR`, `FATAL`, `INFO`, `OFF`, `TRACE` and `WARN`.

Log level can also be changed at runtime, for example (assuming docker exec access):

    ./keycloak/bin/jboss-cli.sh --connect --command='/subsystem=logging/console-handler=CONSOLE:change-log-level(level=DEBUG)'
    ./keycloak/bin/jboss-cli.sh --connect --command='/subsystem=logging/root-logger=ROOT:change-root-log-level(level=DEBUG)'
    ./keycloak/bin/jboss-cli.sh --connect --command='/subsystem=logging/logger=org.keycloak:write-attribute(name=level,value=DEBUG)'

###
```bash
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d @data.txt https://lti-ri.imsglobal.org/lti/tools/1376/login_initiations 
```