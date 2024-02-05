#!/usr/bin/env bash

# values: development, production
export SIMVA_ENVIRONMENT="development"

export SIMVA_DEBUG="false"

[[ "${SIMVA_ENVIRONMENT}" == "development" ]] && SIMVA_DEBUG="true"

export SIMVA_LOGGING_MAX_FILE_SIZE="20m"

export SIMVA_LOGGING_MAX_FILES="5"

export SIMVA_STACKS="00-network 01-traefik 02-keycloak 03-limesurvey 04-minio 05-kafka 06-simva 08-anaconda"

# SIMVA installation folder
export SIMVA_HOME="${SIMVA_PROJECT_DIR}"

export SIMVA_DATA_HOME="${SIMVA_HOME}/data"

export SIMVA_CONFIG_HOME="${SIMVA_HOME}/config"

export SIMVA_TLS_HOME="${SIMVA_CONFIG_HOME}/tls"

export SIMVA_TLS_GENERATE_SELF_SIGNED="false"

[[ "${SIMVA_ENVIRONMENT}" == "development" ]] && SIMVA_TLS_GENERATE_SELF_SIGNED="true"

export SIMVA_CONTAINER_TOOLS_HOME="${SIMVA_CONFIG_HOME}/container-tools"

export SIMVA_SERVICE_NETWORK="traefik_services"

export SIMVA_KEYCLOAK_IMAGE="jboss/keycloak"

export SIMVA_KEYCLOAK_VERSION="10.0.2"

export SIMVA_MARIADB_IMAGE="mariadb"

export SIMVA_MARIADB_VERSION="10.4.13"

export SIMVA_HOST_EXTERNAL_IP="192.168.253.2"

# Network interface used by the shared network "traefik_services"
export SIMVA_NETWORK_INTERFACE="simva0"

# SIMVA's service network CIDR
export SIMVA_NETWORK_CIDR="172.30.0.0/24"

# SIMVA's service network DNS IP
export SIMVA_DNS_SERVICE_IP="172.30.0.53"

export SIMVA_LOAD_BALANCER_IPS="172.30.0.80"

[[ "${SIMVA_ENVIRONMENT}" == "production" ]] && SIMVA_LOAD_BALANCER_IPS="127.0.0.1"

export SIMVA_DEV_LOAD_BALANCER="false"

# Domain used for docker containers hostnames
export SIMVA_INTERNAL_DOMAIN="internal.test"

# Domain used for registering public-faced docker container hostnames
export SIMVA_EXTERNAL_DOMAIN="external.test"

# SIMVA API default user
export SIMVA_API_ADMIN_USERNAME="admin"
export SIMVA_API_ADMIN_EMAIL="${SIMVA_API_ADMIN_USERNAME}@${SIMVA_EXTERNAL_DOMAIN}"
export SIMVA_API_ADMIN_PASSWORD="password"

# tecnativa/socket-proxy logging level, possible values: info, debug
export SIMVA_SOCKET_PROXY_LOG_LEVEL="info"

# dns-proxy-server logging level, possible values: INFO, DEBUG
export SIMVA_DNS_PROXY_SERVER_LOG_LEVEL="INFO"

# Traefik: disables SSL certificate verification
#
# Note: It is far better (and more secure) to config SIMVA_SSL_ROOT_CAS
export SIMVA_TRAEFIK_INSECURE_SKIP_VERIFY="false"

# Traefik: logging levels are DEBUG, PANIC, FATAL, ERROR, WARN, and INFO
export SIMVA_TRAEFIK_LOG_LEVEL="INFO"

# Traefik: control access log generation: true, false
export SIMVA_TRAEFIK_ACCESS_LOG="false"

# Traefik dashboard is protected using basic authentication
export SIMVA_TRAEFIK_DASHBOARD_USER="admin"

# Traefik: passwords must be hashed using MD5, SHA1, or BCrypt.
# Note: Use htpasswd to generate the passwords.
#
# Default: password
# XXX Better use the approach of _FILE variables to read the variable from a file (check file_env)
export SIMVA_TRAEFIK_DASHBOARD_PASSWORD="\\\$apr1\\\$97xk9Kkr\\\$gavbmzhrI6uOVYNOfYByQ/"

export SIMVA_TRAEFIK_EXTRA_CSP_POLICY=""

[[ "${SIMVA_ENVIRONMENT}" == "development" ]] && SIMVA_TRAEFIK_EXTRA_CSP_POLICY=" report-uri https://csp-reporter.${SIMVA_EXTERNAL_DOMAIN}/report-violation; report-to https://csp-reporter.${SIMVA_EXTERNAL_DOMAIN}/report-violation;"

#Traefik: DNS Servers
export SIMVA_TRAEFIK_DNS_SERVER_1="8.8.8.8:53"
export SIMVA_TRAEFIK_DNS_SERVER_2="8.8.4.4:53"

# Traefik: list of certificates (as file paths, or data bytes) that will be set as Root Certificate
# Authorities when using a self-signed TLS certificate
#
# example: foo.crt,bar.crt
export SIMVA_SSL_ROOT_CAS="${SIMVA_DATA_HOME}/tls/ca/isrgrootx1.pem"

# Keycloak mariadb database configuration
export SIMVA_KEYCLOAK_MYSQL_ROOT_PASSWORD="root"
export SIMVA_KEYCLOAK_MYSQL_DATABASE="keycloak"
export SIMVA_KEYCLOAK_MYSQL_USER="keycloak"
export SIMVA_KEYCLOAK_MYSQL_PASSWORD="password"

# Keycloak master realm default user
export SIMVA_KEYCLOAK_ADMIN_USER="admin"
export SIMVA_KEYCLOAK_ADMIN_PASSWORD="password"

export SIMVA_WAIT_TIMEOUT="120"

#Checking time and max retries for KeyCloak, Minio,Kafka and Anaconda availabled
export SIMVA_WAIT_TIME="10"
export SIMVA_MAX_RETRIES="20"

export SIMVA_SSO_HOST="sso.${SIMVA_EXTERNAL_DOMAIN}"
export SIMVA_SSO_REALM="simva"
export SIMVA_SSO_OPENID_CONFIG_URL="https://${SIMVA_SSO_HOST}/auth/realms/${SIMVA_SSO_REALM}/.well-known/openid-configuration"

export SIMVA_LIMESURVEY_MYSQL_ROOT_PASSWORD="root"
export SIMVA_LIMESURVEY_MYSQL_DATABASE="limesurvey"
export SIMVA_LIMESURVEY_MYSQL_USER="limesurvey"
export SIMVA_LIMESURVEY_MYSQL_PASSWORD="password"

export SIMVA_LIMESURVEY_ADMIN_USER="admin"
export SIMVA_LIMESURVEY_ADMIN_PASSWORD="password2"
export SIMVA_LIMESURVEY_ADMIN_NAME="Simva Administrator"
export SIMVA_LIMESURVEY_ADMIN_EMAIL="lime-dev@limesurvey.${SIMVA_EXTERNAL_DOMAIN}"
export SIMVA_LIMESURVEY_DEBUG_ENTRYPOINT="false"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_ADMIN_PASSWORD="password"

export SIMVA_LIMESURVEY_MSMTP_HOST="mail.keycloak.${SIMVA_INTERNAL_DOMAIN}"
export SIMVA_LIMESURVEY_MSMTP_FROM="no-reply@limesurvey.${SIMVA_EXTERNAL_DOMAIN}"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH="/simplesamlphp"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_LOG_LEVEL="INFO"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_NAME="limesurvey"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY="limesurvey-key.pem"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT="limesurvey-fullchain.pem"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT_SUBJ="/C=ES/ST=Madrid/L=Madrid/O=Universidad Complutense de Madrid/OU=e-UCM SIMVA/CN=limesurvey.${SIMVA_INTERNAL_DOMAIN:-internal.test}"

export SIMVA_LIMESURVEY_SAML_PLUGIN_AUTH_SOURCE="limesurvey"
export SIMPLESAMLPHP_SP_IDP_ID="https://${SIMVA_SSO_HOST}/auth/realms/${SIMVA_SSO_REALM}"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_IDP_METADATA_URL="${SIMPLESAMLPHP_SP_IDP_ID}/protocol/saml/descriptor"

export SIMVA_MINIO_ACCESS_KEY="minio"
export SIMVA_MINIO_SECRET_KEY="password"
export SIMVA_MINIO_OPENID_CLIENT_ID="minio"
export SIMVA_MINIO_IDENTITY_OPENID_SCOPES="openid,policy_role_attribute"

export SIMVA_MINIO_MCS_USER="mcs"
export SIMVA_MINIO_MCS_SECRET="password"

export SIMVA_MCS_HMAC_JWT_SECRET="YOURJWTSIGNINGSECRET"
#required to encrypt jwet payload
export SIMVA_MCS_PBKDF_PASSPHRASE="SECRET"
#required to encrypt jwet payload
export SIMVA_MCS_PBKDF_SALT="SECRET"


export SIMVA_CONFLUENT_PLATFORM_VERSION="5.5.0"
export SIMVA_KAFKA_NETWORK="kafka_services"

export SIMVA_KAFKA_CONNECT_SINK_MINIO_URL="https://minio.${SIMVA_EXTERNAL_DOMAIN}"
export SIMVA_KAFKA_CONNECT_SINK_USER="simva-sink"
export SIMVA_KAFKA_CONNECT_SINK_SECRET="password"


export SIMVA_TRACES_TOPIC="traces"
export SIMVA_TRACES_BUCKET_NAME="traces"
export SIMVA_SINK_TOPICS_DIR="kafka-topics"

export SIMVA_FRONT_SSO_CLIENT_ID="simva"
export SIMVA_FRONT_SSO_CLIENT_KEY="secret"

export SIMVA_SSO_ADMIN_USER="administrator"
export SIMVA_SSO_ADMIN_PASSWORD="administrator"

export SIMAV_A2_HOST="a2"
export SIMVA_A2_PORT="3000"
export SIMVA_A2_PROTOCOL="http"
export SIMVA_A2_ADMIN_USER="root"
export SIMVA_A2_ADMIN_PASSWORD="password"
export SIMVA_A2_EXTERNAL="https://analytics.${SIMVA_EXTERNAL_DOMAIN}"

export SIMVA_MAX_UPLOAD_FILE_SIZE="33554432" #32mb

# Portainer: passwords must be hashed using MD5, SHA1, or BCrypt.
# Note: Use htpasswd to generate the passwords and escape $ with \$.
# docker run --rm httpd:2.4-alpine htpasswd -nbB admin 'password' | cut -d ":" -f 21
#
# Default: password
# XXX Better use the approach of _FILE variables to read the variable from a file (check file_env)
export SIMVA_PORTAINER_ADMIN_PASSWORD="\$\$2y\$\$05\$\$bpeBlWUW7tEdwMUn2KcRZeF7WMZnPAHbZZb17elunirVSX8ieIXvy"

export SIMVA_JUPYTER_PASSWORD="password"

########################################################
# ################### KEYCLOAK USERS ###################
# AUX VARIABLES FOR KEYCLOAK prepare_realm_config SCRIPT
########################################################
export SIMVA_LIMESURVEY_USER="${SIMVA_LIMESURVEY_ADMIN_USER}"
export SIMVA_LIMESURVEY_PASSWORD="${SIMVA_LIMESURVEY_ADMIN_PASSWORD}"

export SIMVA_ADMINISTRATOR_USER="${SIMVA_SSO_ADMIN_USER}"
export SIMVA_ADMINISTRATOR_PASSWORD="${SIMVA_SSO_ADMIN_PASSWORD}"

export SIMVA_MINIO_USER="${SIMVA_MINIO_ACCESS_KEY}"
export SIMVA_MINIO_PASSWORD="${SIMVA_MINIO_SECRET_KEY}"

export SIMVA_SIMVA_USER="simva"
export SIMVA_SIMVA_PASSWORD="${SIMVA_API_ADMIN_PASSWORD}"
########################################################
