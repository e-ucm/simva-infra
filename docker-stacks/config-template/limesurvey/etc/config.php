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
        // debug: Set this to 1 if you are looking for errors. If you still get no errors after enabling this
        // then please check your error-logs - either in your hosting provider admin panel or in some /logs directory
        // on your webspace.
        // LimeSurvey developers: Set this to 2 to additionally display STRICT PHP error messages and put MySQL in STRICT mode and get full access to standard themes
        'debug'=>{{ .debug }},
        //1 to enable sql logging, only active when debug = 2
        'debugsql'=>0,
        // 'force_xmlsettings_for_survey_rendering' => true, // Uncomment if you want to force the use of the XML file rather than DB (for easy theme development)
        // 'use_asset_manager'=>true, // Uncomment if you want to use debug mode and asset manager at the same time
        // Update default LimeSurvey config here
        'WebhookSettings' => [
            'fixed' => [
                'sUrl' => '{{ .plugins.webhooks.url }}',
                'sAuthToken' => '{{ .plugins.webhooks.api_token }}',
                'sHeaderSignatureName' => '{{ .plugins.webhooks.header_name }}',
                'sHeaderSignaturePrefix' => '{{ .plugins.webhooks.header_prefix }}',
                'sId'=> '',
                'events' => '{"surveyStatus":{"afterSurveyComplete":true,"beforeSurveyPage":true}}'
            ],
            'hidden' => ['sAuthToken'],
            'sBug' => '{{ .plugins.webhooks.debug }}'
        ],
        'XAPITrackerSettings' => [
            'sBug' => '{{ .plugins.xapitracker.debug }}',
            'fixed' => [
                'baseUrlLRC' => '{{ .plugins.xapitracker.baseUrlLRC }}',
                'usernameLRC' => '{{ .plugins.xapitracker.usernameLRC }}',
                'passwordLRC' => '{{ .plugins.xapitracker.passwordLRC }}',
                'actorHomepage' => '{{ .plugins.xapitracker.actorhomepage }}',
                'surveylrsendpoint' => '{{ .plugins.xapitracker.surveylrsendpoint }}',
                'oAuthType' => '{{ .plugins.xapitracker.oAuthType }}',
                'usernameOAuth' => '{{ .plugins.xapitracker.usernameOAuth }}',
                'passwordOAuth' => '{{ .plugins.xapitracker.passwordOAuth }}',
                'OAuth2TokenEndpoint' => '{{ .plugins.xapitracker.keycloak_realm_url }}/token',
                'OAuth2LogoutEndpoint' => '{{ .plugins.xapitracker.keycloak_realm_url }}/logout',
                'OAuth2ClientId' => '{{ .plugins.xapitracker.OAuth2ClientId }}',
                'sId'=> '',
            ],
            'hidden' => ['sToken', 'usernameLRC', 'passwordLRC'],
        ],
		'AuthOAuth2Settings' => [
			'fixed' => [
				'client_id' => '{{ .plugins.oauth2.client_id }}',
				'client_secret' => '{{ .plugins.oauth2.client_secret }}',
				'authorize_url' => '{{ .plugins.oauth2.keycloak_realm_url }}/protocol/openid-connect/auth',
				'access_token_url' => '{{ .plugins.oauth2.keycloak_realm_url }}/protocol/openid-connect/token',
                'logout_url' => '{{ .plugins.oauth2.keycloak_realm_url }}/protocol/openid-connect/logout',
				'resource_owner_details_url' => '{{ .plugins.oauth2.keycloak_realm_url }}/protocol/openid-connect/userinfo',
				'is_default' => '',
                'scopes' => 'openid roles profile email',
                'roles_key' => 'realm_access.roles',
                'introduction_text' => 'Logging via Keycloak with OAuth2',
                'button_text' => 'Login',
                'key_separator' => '.',
                'word_separator' => '+',
                'roles_update' => 'true',
                'roles_needed' => 'true',
                'scope_separator' => ' ',
                'roles_to_check' => 'teacher',
                'roles_to_check_separator' => ',',
                'identifier_attribute' => 'username',
			    'username_key' => 'preferred_username',
                'display_separator_username' => '.',
			    'email_key' => 'email',
			    'display_name_key' => 'preferred_username',
                'display_separator_display_name' => ' ',
                'autocreate_users' => 'true',
                'autocreate_permissions' => '{ "users": { "create": false, "read": false, "update": false, "delete": false }, "usergroups": { "create": false, "read": false,"update": false, "delete": false }, "labelsets": { "create": false, "read": false, "update": false, "delete": false, "import": false, "export": false }, "templates": { "create": false, "read": false, "update": false, "delete": false, "import": false, "export": false }, "settings": { "read": false, "update": false, "import": false }, "surveys": { "create": true, "read": true, "update": true, "delete": true, "export": true }, "participantpanel": { "create": false, "read": false, "update": false, "delete": false, "import": false, "export": false }, "auth_db": { "read": false } }'
			],
			'hidden' => ['client_id','client_secret'],
            'debug' => '{{ .plugins.oauth2.debug }}',
		],
        /**
        * This parameter enables/disables the RPC interface
        * Set to 'json' (for JSON-RPC) or 'xml' (for XML-RPC) to enable and 'off' to disable
        * @var string
        */
        'RPCInterface' => 'json',
        'rpc_publish_api' => true,
        /**
        * Sets if any part of LimeSUrvey may be embedded in an iframe
        * Valid values are allow, sameorigin
        * Default / Recommended: sameorigin
        * To disable the header, set it to allow
        * Using 'deny' is currently not supported as it will disable the theme editor preview and probably file upload.
        */
        'x_frame_options' => 'allow',

        /**
        * @var $force_ssl string - forces LimeSurvey to run through HTTPS or to block HTTPS
        *   'on' =  force SSL/HTTPS to be on (This will cause LimeSurvey
        *       to fail in SSL is turned off)
        *   Any other string value = do nothing (default)
        *
        * DO NOT turn on secure unless you are sure SSL/HTTPS is working and
        * that you have a current, working, valid certificate. If you are
        * unsure whether your server has a valid certificate, just add 's'
        * to the http part of your normal LimeSurvey URL.
        *   e.g. https://your.domain.org/limesurvey/admin/admin.php
        * If LimeSurvey comes up as normal, then everything is fine. If you
        * get a page not found error or permission denied error then
        */
        'force_ssl' => 'on', // DO not turn on unless you are sure your server supports SSL/HTTPS
    ),
);
/* End of file config.php */
/* Location: ./application/config/config.php */