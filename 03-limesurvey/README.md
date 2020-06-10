# LimeSurvey setup

The perform the following steps:
1. Verify `03-limesurvey_limesurvey_1` container is running
2. Access [https://limesurvey.external.test/simplesamlphp/](https://limesurvey.external.test/simplesamlphp/).
3. Log in (password: `admin`).
4. Go to *Federation* section.
5. Within **SAML 2.0 SP Metadata**, section click on [Show Metadata](https://limesurvey.external.test/simplesamlphp/module.php/saml/sp/metadata.php/https___sso_external_test_auth_realms_simva?output=xhtml) of the subsection *https___sso_external_test_auth_realms_simva*
6. Click on [get the metadata xml on a dedicated URL](https://limesurvey.external.test/simplesamlphp/module.php/saml/sp/metadata.php/default-sp)
7. Save the *https___sso_external_test_auth_realms_simva* file.
8. Go to [SIMVA's KeyCloak realm clients configuration](https://sso.external.test/auth/admin/master/console/#/realms/simva/clients)
9. Click *CREATE* button
10. Click *Select file* button of the Import option. Select the *https___sso_external_test_auth_realms_simva* file previously downloaded.
11. Click *Save* button.
12. Click on *Client Scopes* tab.
13. Add all `saml_*` client scopes.
14. Access [SimpleSAMLphp's example authentication section](https://limesurvey.external.test/simplesamlphp/module.php/core/frontpage_auth.php).
15. Click on [*Test configured authentication sources*](https://limesurvey.external.test/simplesamlphp/module.php/core/authenticate.php)
16. Click on [*https___sso_external_test_auth_realms_simva*](https://limesurvey.external.test/simplesamlphp/module.php/core/authenticate.php?as=https___sso_external_test_auth_realms_simva)
17. Register a new user or authenticate with an existing one.
> Note: If you register a new user, go to [mail-dev](https://mail.external.test/) and click on the email you received.
18. The SimpleSAMLphp appears again with the autentication data.