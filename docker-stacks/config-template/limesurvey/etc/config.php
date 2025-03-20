<?php if (!defined('BASEPATH')) {
    exit('No direct script access allowed');
}
/*
| -------------------------------------------------------------------
| DATABASE CONNECTIVITY SETTINGS
| -------------------------------------------------------------------
| This file will contain the settings needed to access your database.
|
| For complete instructions please consult the 'Database Connection'
| page of the User Guide.
|
| -------------------------------------------------------------------
| EXPLANATION OF VARIABLES
| -------------------------------------------------------------------
|
|   'connectionString' Hostname, database, port and database type for
|    the connection. Driver example: mysql. Currently supported:
|               mysql, pgsql, mssql, sqlite, oci
|   'username' The username used to connect to the database
|   'password' The password used to connect to the database
|   'tablePrefix' You can add an optional prefix, which will be added
|               to the table name when using the Active Record class
|
*/
return array(
    'components' => array(
        'db' => array(
            'connectionString' => 'mysql:host={{ .db.url }};port=3306;dbname={{ .db.database }};',
            'emulatePrepare' => true,
            'username' => '{{ .db.user }}',
            'password' => '{{ .db.password }}',
            'charset' => 'utf8mb4',
            'attributes' => array(),
            'tablePrefix' => '',
        ),

        // Uncomment the following lines if you need table-based sessions.
        // Note: Table-based sessions are currently not supported on MSSQL server.
        // 'session' => array (
            // 'class' => 'application.core.web.DbHttpSession',
            // 'connectionID' => 'db',
            // 'sessionTableName' => '{sessions}',
        // ),

        'urlManager' => array(
            'urlFormat' => 'path',
            'rules' => array(
                // You can add your own rules here
            ),
            'showScriptName' => false,
        ),

    ),
    // Use the following config variable to set modified optional settings copied from config-defaults.php
    'config'=>array(
        // Update default LimeSurvey config here
        'WebHookStatusSettings' => [
            'fixed' => [
                'sWebhookUrl' => '{{ .plugins.webhooks.url }}',
            ],
            'sBug' => '{{ .plugins.webhooks.debug }}'
        ],
		'AuthOAuth2Settings' => [
			'fixed' => [
				'client_id' => '{{ .plugins.oauth2.client_id }}',
				'client_secret' => '{{ .plugins.oauth2.client_secret }}',
				'authorize_url' => '{{ .plugins.oauth2.keycloak_realm_url }}/protocol/openid-connect/auth',
				'access_token_url' => '{{ .plugins.oauth2.keycloak_realm_url }}/protocol/openid-connect/token',
				'resource_owner_details_url' => '{{ .plugins.oauth2.keycloak_realm_url }}/protocol/openid-connect/userinfo',
				'is_default' => '',
                'scopes' => 'openid roles profile email',
                'roles_key' => 'realm_access.roles',
                'key_separator' => '.',
                'roles_update' => 'true',
                'roles_needed' => 'true',
                'scope_separator' => ' ',
                'roles_to_check' => 'teacher',
                'roles_to_check_separator' => ',',
			],
			'hidden' => ['client_id','client_secret'],
            'debug' => '{{ .plugins.oauth2.debug }}',
			'identifier_attribute' => 'username',
			'username_key' => 'preferred_username',
			'email_key' => 'email',
			'display_name_key' => 'preferred_username',
            'autocreate_users' => 'true',
            'autocreate_permissions' => '{ "users": { "create": false, "read": false, "update": false, "delete": false }, "usergroups": { "create": false, "read": false,"update": false, "delete": false }, "labelsets": { "create": false, "read": false, "update": false, "delete": false, "import": false, "export": false }, "templates": { "create": false, "read": false, "update": false, "delete": false, "import": false, "export": false }, "settings": { "read": false, "update": false, "import": false }, "surveys": { "create": true, "read": true, "update": true, "delete": true, "export": true }, "participantpanel": { "create": false, "read": false, "update": false, "delete": false, "import": false, "export": false }, "auth_db": { "read": false } }',
		],
        // debug: Set this to 1 if you are looking for errors. If you still get no errors after enabling this
        // then please check your error-logs - either in your hosting provider admin panel or in some /logs directory
        // on your webspace.
        // LimeSurvey developers: Set this to 2 to additionally display STRICT PHP error messages and put MySQL in STRICT mode and get full access to standard themes
        'debug'=>0,
        'debugsql'=>0,
        // 'force_xmlsettings_for_survey_rendering' => true, // Uncomment if you want to force the use of the XML file rather than DB (for easy theme development)
        // 'use_asset_manager'=>true, // Uncomment if you want to use debug mode and asset manager at the same time
        // Update default LimeSurvey config here
        'class' => 'application.core.components.Config',
            'settings' => array(
                'global' => array(
                    'allowiframe' => '1'
                )
            )
    )
);
/* End of file config.php */
/* Location: ./application/config/config.php */