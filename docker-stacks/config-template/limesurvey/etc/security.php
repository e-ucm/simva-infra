<?php

return array(

    // === Limesurvey Encryption Keys (5.x+) ===
    // These are randomly generated, must be kept secret!
    'ENCRYPT_NONCE' => '{{ .encrypt.nonce }}',  // 24-byte base64 string
    'ENCRYPT_SECRET_BOX_KEY' => '{{ .encrypt.secretboxkey }}',  // 32-byte base64 string

    // === SESSION & COOKIE SECURITY ===
    'sessionName' => 'LSSESSID',
    'cookieSecure' => true,
    'cookieHttpOnly' => true,
    'cookieSameSite' => 'Lax',

    // === AUTHORISATION ===
    'force_secure_password' => true,
    'enableLoginAttemptControl' => true,
    'maxLoginAttempts' => 5,
    'timeOutLoginAttempt' => 900,

    // === CSRF & XSS PROTECTION ===
    'use_csrf_token' => true,
    'CSRFProtection' => true,
    'disallow_multi_csrf' => true,
    'force_htmlpurify' => true,

    // === FILE UPLOAD & EXECUTION SAFETY ===
    'allowedFileTypes' => 'jpeg,jpg,png,gif,pdf,doc,docx,xls,xlsx,txt',
    'allowedFileSize' => 16,
    'allowURLfOpen' => false,
    'restrictAdminScripts' => true,

    // === HTTP / REVERSE PROXY SECURITY ===
    'proxyHostIP' => ['127.0.0.1', '::1'],
    'force_ssl' => true,
    'headers' => array(
        'X-Frame-Options' => 'ALLOW',
        'X-Content-Type-Options' => 'nosniff',
        'Referrer-Policy' => 'strict-origin-when-cross-origin',
        'X-XSS-Protection' => '1; mode=block'
    ),

    // === ADMIN PANEL HARDENING ===
    'adminThemeTester' => false,
    'debugsql' => 0,
    'debug' => 0,
);
