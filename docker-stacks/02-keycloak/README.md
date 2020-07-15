Currently when keycloak is launched and there is no `simva` realm, it is imported automatically using the sample realm. This sample realm configures:
- Composite roles (student, teaching-assistant, teacher, researcher, administrator)
- The teacher role has an attributte `policy` to allow for minio
> Note: we should add the same attribute to the reseacher role
- Client scopes
- Minio client
- Limesurvey client. **NOTE: Because LS generates a x509 to sign and/or encrypt SAML2 interactions at launch time it is needed to replace the `SAML Keys>Signing Key / Encryption Key` with the file that is available at `simplesamlphp-data/config/certs/example.crt`

Moreover there are some sample users:
- Student
  - Username: student
  - Password: student
  - Role: student
- Teaching-assistant
  - Username: teaching-assistant
  - Password: teaching-assistant
  - Role: teaching-assistant
- Teacher
  - Username: teacher
  - Password: teacher
  - Role: teacher
- Researcher
  - Username: researcher
  - Password: researcher
  - Role: researcher
- Administrator
  - Username: administrator
  - Password: administrator
  - Role: administrator

## Manual Keycloak *SIMVA* realm setup
1. Add new REALM
2. Realm Settings
    - Login options, enable:
      - User registration
      - Forgot password
      - Verify email
      - Login with email
      - Require SSL: all requests
    - Emails:
      - Host: mail.keycloak.internal.test
      - Port: 25
      - From display name: SIMVA SSO
      - From: no-reply@simva.external.test
      - Reply To Display Name: No Reply
3. Roles:
    - Add the following roles: student, teaching-assistant, teacher, researcher and administrator roles
    - Roles are composite roles
> Note: A composite role is a role that has one or more additional roles associated with it. When a composite role is mapped to the user, the user also gains the roles associated with that composite. This inheritance is recursive so any composite of composites also gets inherited (source: https://www.keycloak.org/docs/latest/server_admin/#_composite-roles).
4. Client Scopes:
    - saml_fullname
      - Settings:
        - Name: saml_fullname
        - Description: User Full name
        - protocol: saml
      - Mappers
        - Name: fullname
        - Category: AttributeStatement Mapper
        - Mapper Type: Javascript Mapper
          - Script:
                ```
                /**
                * Available variables: 
                * user - the current user
                * realm - the current realm
                * clientSession - the current clientSession
                * userSession - the current userSession
                * keycloakSession - the current userSession
                */
                var firstName = user.getFirstName();
                var lastName = user.getLastName();
                firstName + ' ' + lastName;
                ```
        - Friendly name: User's Full name
        - SAML Attribute Name: name
        - SAML Attribute NameFormat: Basic
    - saml_group_list
      - Settings:
        - Name: saml_group_list
        - Description: User's groups
        - protocol: saml
      - Mappers
        - Name: group_list
        - Category: Group Mapper
        - Mapper Type: Group list
          - Group attribute name: member
          - Friendly name: Group where the user participates
          - SAML Attribute NameFormat: Basic
          - Single Group Attribute: off
          - Full group path: on
    - saml_mail
      - Settings:
        - Name: saml_mail
        - Description: User email
        - protocol: saml
      - Mappers
        - Name: mail
        - Category: AttributeStatement Mapper
        - Mapper Type: User Property
          - Property: email
          - Friendly name: User email
          - SAML Attribute Name: mail
          - SAML Attribute NameFormat: Basic
        - Name: email verified
        - Category: AttributeStatement Mapper
        - Mapper Type: User Property
          - Property: emailVerified
          - Friendly name: Represent if the user's email has been verified
          - SAML Attribute Name: email_verified
          - SAML Attribute NameFormat: Basic
    - saml_uid
      - Settings:
        - Name: saml_uid
        - Description: User identifier
        - protocol: saml
      - Mappers
        - Name: uid
        - Category: AttributeStatement Mapper
        - Mapper Type: User Property
          - Property: id
          - Friendly name: User identifier
          - SAML Attribute Name: uid
          - SAML Attribute NameFormat: Basic
    - saml_username
      - Settings:
        - Name: saml_username
        - Description: User's username
        - protocol: saml
      - Mappers
        - Name: username
        - Category: AttributeStatement Mapper
        - Mapper Type: User Property
          - Property: username
          - Friendly name: User name
          - SAML Attribute Name: username
          - SAML Attribute NameFormat: Basic

# Examples

The file `examples.yml` allow to deploy two example containers that can be used to test Keycloak.
- containous/whoami. To verify traefik headers.
- eucm/simplesamlphp. To verify Keycloak as a SAML2 IdP.
```
cd /home/vagrant/02-keycloak
docker-compose -f examples.yml up -d
```

Then perform the following steps:
1. Verify `02-keycloak_simplesamlphp_1` container is running
2. Access [https://simplesamlphp.external.test/simplesamlphp/](https://simplesamlphp.external.test/simplesamlphp/).
3. Log in (password: `admin`).
4. Go to *Federation* section.
5. Within **SAML 2.0 SP Metadata**, section click on [Show Metadata](https://simplesamlphp.external.test/simplesamlphp/module.php/saml/sp/metadata.php/https___sso_external_test_auth_realms_simva?output=xhtml) of the subsection *https___sso_external_test_auth_realms_simva*
6. Click on [get the metadata xml on a dedicated URL](https://simplesamlphp.external.test/simplesamlphp/module.php/saml/sp/metadata.php/default-sp)
7. Save the *https___sso_external_test_auth_realms_simva* file.
8. Go to [SIMVA's KeyCloak realm clients configuration](https://sso.external.test/auth/admin/master/console/#/realms/simva/clients)
9. Click *CREATE* button
10. Click *Select file* button of the Import option. Select the *https___sso_external_test_auth_realms_simva* file previously downloaded.
11. Click *Save* button.
12. Click on *Client Scopes* tab.
13. Add all `saml_*` client scopes.
14. Access [SimpleSAMLphp's example authentication section](https://simplesamlphp.external.test/simplesamlphp/module.php/core/frontpage_auth.php).
15. Click on [*Test configured authentication sources*](https://simplesamlphp.external.test/simplesamlphp/module.php/core/authenticate.php)
16. Click on [*https___sso_external_test_auth_realms_simva*](https://simplesamlphp.external.test/simplesamlphp/module.php/core/authenticate.php?as=https___sso_external_test_auth_realms_simva)
17. Register a new user or authenticate with an existing one.
> Note: If you register a new user, go to [mail-dev](https://mail.external.test/) and click on the email you received.
18. The SimpleSAMLphp appears again with the autentication data.

# Keycloak Import / Export realms (including users)

It is not possible to make a full backup (including users) from the Keycloak's UI, but it is possible to do it from the terminal. Use the snipets of the following sections to create export (backup) a realm and how to import (restore) a backup.

## Export
```
docker run --rm \
    --name keycloak_exporter \
    -v /tmp:/tmp/keycloak-export:Z \
    -e DB_VENDOR=mariadb \
    -e DB_ADDR=mariadb.keycloak.${SIMVA_INTERNAL_DOMAIN:-internal.test} \
    -e DB_DATABASE=${SIMVA_KEYCLOAK_MYSQL_DATABASE:-keycloak} \
    -e DB_USER=${SIMVA_KEYCLOAK_MYSQL_USER:-keycloak} \
    -e DB_PASSWORD=${SIMVA_KEYCLOAK_MYSQL_PASSWORD:-password} \
    --network 02-keycloak_default \
    ${SIMVA_KEYCLOAK_IMAGE:-jboss/keycloak}:${SIMVA_KEYCLOAK_VERSION:-10.0.2} \
    -Dkeycloak.migration.action=export \
    -Dkeycloak.migration.provider=dir \
    -Dkeycloak.migration.dir=/tmp/keycloak-export \
    -Dkeycloak.migration.usersExportStrategy=SAME_FILE \
    -Dkeycloak.migration.realmName=${1:-simva}
```
## Import
```
docker run --rm \
    --name keycloak_importer \
    -v /tmp:/tmp/keycloak-import:Z \
    -e DB_VENDOR=mariadb \
    -e DB_ADDR=mariadb.keycloak.${SIMVA_INTERNAL_DOMAIN:-internal.test} \
    -e DB_DATABASE=${SIMVA_KEYCLOAK_MYSQL_DATABASE:-keycloak} \
    -e DB_USER=${SIMVA_KEYCLOAK_MYSQL_USER:-keycloak} \
    -e DB_PASSWORD=${SIMVA_KEYCLOAK_MYSQL_PASSWORD:-password} \
    --network 02-keycloak_default \
    ${SIMVA_KEYCLOAK_IMAGE:-jboss/keycloak}:${SIMVA_KEYCLOAK_VERSION:-10.0.2} \
    -Dkeycloak.migration.action=import \
    -Dkeycloak.migration.provider=dir \
    -Dkeycloak.migration.dir=/backups \
    -Dkeycloak.migration.strategy=IGNORE_EXISTING \
    -Dkeycloak.migration.usersExportStrategy=SAME_FILE \
    -Dkeycloak.migration.realmName=${1:-simva}
```

# References
- https://stackoverflow.com/questions/48930281/export-all-users-from-keycloak
- https://www.keycloak.org/docs/latest/server_admin/#_export_import