# Minio setup

## Create / Modify a Keycloak user

You need to create a keycloak user inside the `simva` realm. In addition, you need to add a *user's attribute* name `policy`. The possible values are:
 - `readonly-user-folder-jwt`. This policy allows the user to access `traces/users/<USER_ID>` folder and read the files there.
 - `write-user-folder-jwt`. This policy allows the user to access to the `traces/users/<USER_ID>` folder and read, write and delete files.

That corresponds to the canned policy names that are installed when minio is launched the first time.

## Prepare some sample files

1. Launch the docker-compose unit.
2. Go to [minio-KeyCloak doc](https://github.com/minio/minio/blob/master/docs/sts/keycloak.md#2-configure-keycloak) and configure a client in KeyCloak for minio.
3. Go to [https://minio.external.test/](https://minio.external.test/)
4. Login as super admin
    * User: minio
    * Password: password
5. Create at least two folders: `users/other`, `users/userID` where *userID* is the user ID of an already existing account in Keycloak (Check Manage > Users in simva realm, `d9dad277-ecfb-4b37-9c91-3f47cdb501d6`).
> Note: Upload at least one file in each of the folders. Beware that minio does not support empty folders, that is, if you leave empty the folder it does not exists at all.

## Create a client for minio in Keycloak

1. Go to [https://sso.external.test](https://sso.external.test).
2. Create a new client scope
  * openid_user_policy
    * Settings
      * Name: openid_user_policy
      * Description: User's policy
      * Display On consent screen: Off
    * Mappers
      * Name: user_policy
      * Mapper Type: User Attribute
      * Property: policy
      * Token Claim Name: policy
      * Claim JSON Type: string
  * policy_role_attribute
    * Settings:
      * Name: policy_role_attribute
      * Description: Policy role attribute
      * Display On consent screen: Off
    * Mappers:
      * Name: policy_role_attribute
      * Mapper Type: Policy Role attribute mapper (Note: this type is custom mapper see [02-keycloack/scripts/README.md](02-keycloack/scripts/README.md))
      * Multivalued: Off (Note: the by default the mapper may return multiple values if there is a policy attribute in multiple roles, however minio seems to expect just one value)
      * Tocken Claim Name: policy
      * Claim JSON Type String
> NOTE: It is mandatory to add all available scopes due to [minio/issues/9238](https://github.com/minio/minio/issues/9238). Monitor the issue to just enable the minimum required scopes.
3. Create a new OpenID client
  * Client ID: Use the value defined in docker-compose `MINIO_IDENTITY_OPENID_CLIENT_ID` environment variable (e.g. `https://minio.external.test`)
  * Root URL: Define the base URL for minio (e.g. `https://minio.external.test`)
  * Settings:
    * Implicit Flow: On
    * Advanced Settings:
      * Access Token Lifespan: 1 Hours
  * Client Scopes:
    * Default Client Scopes:
      * Add `openid_user_policy` created before so it appears in *Asigned Default Client Scopes*


### References

- https://github.com/minio/minio/issues/7394#issuecomment-476552537
- https://github.com/minio/minio/blob/master/docs/sts/web-identity.md
- https://github.com/minio/minio/blob/master/docs/sts/keycloak.md
- https://github.com/minio/minio/blob/master/docs/sts/wso2.md