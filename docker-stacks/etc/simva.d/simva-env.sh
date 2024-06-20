#!/usr/bin/env bash

###############################
# SIMVA ENVIRONMENT AND DEBUG #
###############################
# values: development, production
export SIMVA_ENVIRONMENT="development"
export SIMVA_DEVELOPMENT_LOCAL="false"

export SIMVA_DEBUG="false"
[[ "${SIMVA_ENVIRONMENT}" == "development" ]] && SIMVA_DEBUG="true"

#######################
# SIMVA LOGGING FILES #
#######################
# SIMVA Logging max file size
export SIMVA_LOGGING_MAX_FILE_SIZE="20m"
# SIMVA Logging max files
export SIMVA_LOGGING_MAX_FILES="5"
# SIMVA Max Upload file size
export SIMVA_MAX_UPLOAD_FILE_SIZE="33554432" #32mb

################
# SIMVA STACKS #
################
export SIMVA_STACKS="00-network 01-traefik 02-keycloak 03-limesurvey 04-minio 05-kafka 06-simva 08-anaconda 09-logs"

#############################
# SIMVA installation folder #
#############################
export SIMVA_HOME="${SIMVA_PROJECT_DIR}"

export SIMVA_DATA_HOME="${SIMVA_HOME}/data"

export SIMVA_CONFIG_HOME="${SIMVA_HOME}/config"

export SIMVA_TLS_HOME="${SIMVA_CONFIG_HOME}/tls"

export SIMVA_TLS_GENERATE_SELF_SIGNED="false"

[[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]] && SIMVA_TLS_GENERATE_SELF_SIGNED="true"

export SIMVA_CONTAINER_TOOLS_HOME="${SIMVA_CONFIG_HOME}/container-tools"

###########################################
# Images versions and SIMVA Git reference #
###########################################
# Images versions
export SIMVA_TRAEFIK_IMAGE="traefik"
export SIMVA_TRAEFIK_VERSION="2.11.3"

export SIMVA_KEYCLOAK_IMAGE="quay.io/keycloak/keycloak"
export SIMVA_KEYCLOAK_VERSION="24.0.2"

export SIMVA_MARIADB_IMAGE="mariadb"
export SIMVA_MARIADB_VERSION="10.4.13"

export SIMVA_LIMESURVEY_IMAGE="eucm/limesurvey"
export SIMVA_LIMESURVEY_VERSION="4.3.15-4"

export SIMVA_MINIO_IMAGE="minio/minio"
export SIMVA_MINIO_VERSION="RELEASE.2020-09-26T03-44-56Z"
export SIMVA_MINIO_MC_IMAGE="minio/mc"
export SIMVA_MINIO_MC_VERSION="RELEASE.2020-09-03T00-08-28Z"

export SIMVA_KAFKA_IMAGE="confluentinc/cp-kafka"
export SIMVA_KAFKA_CONNECT_IMAGE="confluentinc/cp-kafka-connect"
export SIMVA_KAFKA_VERSION="5.5.0"
export SIMVA_ZOOKEEPER_IMAGE="zookeeper"
export SIMVA_ZOOKEEPER_VERSION="3.4.9"

export SIMVA_SIMVA_IMAGE="node"
export SIMVA_SIMVA_VERSION="20.9.0-bullseye"

export SIMVA_MONGODB_IMAGE="mongo"
export SIMVA_MONGODB_VERSION="4.2.8"

export SIMVA_ANACONDA_IMAGE="continuumio/anaconda3"
export SIMVA_ANACONDA_VERSION="2024.02-1"

export SIMVA_PORTAINER_IMAGE="portainer/portainer-ce"
export SIMVA_PORTAINER_VERSION="latest"

export SIMVA_DOZZLE_IMAGE="amir20/dozzle"
export SIMVA_DOZZLE_VERSION="latest"
#Git reference branch
export CSP_REPORTER_GIT_REF="master"
branch="master"
[[ "${SIMVA_ENVIRONMENT:-production}" == "development" ]] && branch="dev"
export SIMVA_API_GIT_REF=$branch
export SIMVA_FRONT_GIT_REF=$branch
export SIMVA_TRACE_ALLOCATOR_GIT_REF=$branch

base_for_simva_repos="${SIMVA_DATA_HOME}/simva"
[[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]] && base_for_simva_repos="${SIMVA_HOME}/../.."
if [[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]]; then
    export SIMVA_API_GIT_REPO="${base_for_simva_repos}/simva"
else 
    export SIMVA_API_GIT_REPO="${base_for_simva_repos}/simva-api"
fi
export SIMVA_FRONT_GIT_REPO="${base_for_simva_repos}/simva-front"
export SIMVA_TRACE_ALLOCATOR_GIT_REPO="${base_for_simva_repos}/simva-trace-allocator"

export SIMVA_KEYCLOAK_EVENT_GIT_REF="v0.26"

###################
# Service Network #
###################
# Service Network
export SIMVA_SERVICE_NETWORK="traefik_services"

#Simva External IP
export SIMVA_HOST_EXTERNAL_IP="172.30.0.1"

# Network interface used by the shared network "traefik_services"
export SIMVA_NETWORK_INTERFACE="simva0"

# SIMVA's service network CIDR
export SIMVA_NETWORK_CIDR="172.30.0.0/24"

# SIMVA Load Balancer IPs
export SIMVA_DEV_LOAD_BALANCER="false"
export SIMVA_LOAD_BALANCER_IPS="172.30.0.80"
[[ "${SIMVA_ENVIRONMENT}" == "production" ]] && SIMVA_LOAD_BALANCER_IPS="127.0.0.1"

# Determine the current operating system and architecture
export SIMVA_SYSTEM_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case $(uname -m) in
    "x86_64") 
        export SIMVA_SYSTEM_ARCHITECTURE="amd64";;
    "i386") 
        export SIMVA_SYSTEM_ARCHITECTURE="386";;
    "i686") 
        export SIMVA_SYSTEM_ARCHITECTURE="686";;
    *) 
        export SIMVA_SYSTEM_ARCHITECTURE=$(uname -m);;
esac

########################
# Domain and subdomain #
########################
# Domain used for docker containers hostnames
export SIMVA_INTERNAL_DOMAIN="internal.test"
# Domain used for registering public-faced docker container hostnames
export SIMVA_EXTERNAL_DOMAIN="external.test"
# External protocol
export SIMVA_EXTERNAL_PROTOCOL="https"
# Traefik Host
export SIMVA_TRAEFIK_HOST_SUBDOMAIN="traefik"
#Keyclock Simva SSO Host
export SIMVA_SSO_HOST_SUBDOMAIN="sso"
#Mail Host
export SIMVA_MAIL_HOST_SUBDOMAIN="mail"
export SIMVA_MAIL_PORT="25"
#Limesurvey host
export SIMVA_LIMESURVEY_HOST_SUBDOMAIN="limesurvey"
#Minio host
export SIMVA_MINIO_HOST_SUBDOMAIN="minio"
#Analytics A2 host
export SIMVA_ANALYTICS_HOST_SUBDOMAIN="analytics"
#SIMVA MONGO DB 
export SIMVA_MONGO_HOST_SUBDOMAIN="simva-mongo"
#SIMVA API
export SIMVA_SIMVA_API_HOST_SUBDOMAIN="simva-api"
export SIMVA_SIMVA_API_PORT="443"
#Jupyter Notebook
export SIMVA_JUPYTER_HOST_SUBDOMAIN="jupyter"
#LOGS
export SIMVA_DOZZLE_HOST_SUBDOMAIN="logs"
export SIMVA_PORTAINER_HOST_SUBDOMAIN="portainer"

#####################
# Socket Proxy info #
#####################
# tecnativa/socket-proxy logging level, possible values: info, debug
export SIMVA_SOCKET_PROXY_LOG_LEVEL="info"

################
# Traefik info #
################
# Traefik: disables SSL certificate verification
#
# Note: It is far better (and more secure) to config SIMVA_SSL_ROOT_CAS
export SIMVA_TRAEFIK_INSECURE_SKIP_VERIFY="false"

# Traefik: logging levels are DEBUG, PANIC, FATAL, ERROR, WARN, and INFO
export SIMVA_TRAEFIK_LOG_LEVEL="INFO"

# Traefik: control access log generation: true, false
export SIMVA_TRAEFIK_ACCESS_LOG="false"
export SIMVA_TRAEFIK_EXTRA_CSP_POLICY=""
[[ "${SIMVA_ENVIRONMENT}" == "development" ]] && SIMVA_TRAEFIK_EXTRA_CSP_POLICY=" report-uri https://csp-reporter.${SIMVA_EXTERNAL_DOMAIN}/report-violation; report-to https://csp-reporter.${SIMVA_EXTERNAL_DOMAIN}/report-violation;"

# Traefik: list of certificates (as file paths, or data bytes) that will be set as Root Certificate
# Authorities when using a self-signed TLS certificate
#
# example: foo.crt,bar.crt
export SIMVA_SSL_ROOT_CAS="${SIMVA_DATA_HOME}/tls/ca/isrgrootx1.pem"

#Truststore CA Alias
export SIMVA_TRUSTSTORE_CA_ALIAS='simvaCA'

###################################################################
# Checking time for KeyCloak, Minio,Kafka and Anaconda availabled #
###################################################################
#Checking time and max retries for KeyCloak, Minio,Kafka and Anaconda availabled
export SIMVA_WAIT_TIMEOUT="120"
export SIMVA_WAIT_TIME="15"
export SIMVA_MAX_RETRIES="20"

#################
# Keycloak info #
#################
export SIMVA_SSO_REALM="simva"
export SIMVA_KEYCLOAK_MYSQL_DATABASE="keycloak"
export SIMVA_SSO_LOG_LEVEL="info"

#################
# Mail SSO info #
#################
export SIMVA_MAIL_FROM_USERNAME="noreply"
export SIMVA_MAIL_REPLYTO_USERNAME="noreply"
export SIMVA_MAIL_SSL="false"
export SIMVA_MAIL_STARTTLS="false"

###################
# Limesurvey info #
###################
export SIMVA_LIMESURVEY_MYSQL_DATABASE="limesurvey"
export SIMVA_LIMESURVEY_ADMIN_NAME="Simva Administrator"
export SIMVA_LIMESURVEY_ADMIN_EMAIL_USERNAME="lime-dev"
export SIMVA_LIMESURVEY_DEBUG_ENTRYPOINT="false"

###################################
# Limesurvey SIMPLE SAML PHP info #
###################################
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_PATH="/simplesamlphp"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_LOG_LEVEL="INFO"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_PRIVATE_KEY="limesurvey-key.pem"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT="limesurvey-fullchain.pem"
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_SP_CERT_SUBJ="/C=ES/ST=Madrid/L=Madrid/O=Universidad Complutense de Madrid/OU=e-UCM SIMVA/CN=${SIMVA_LIMESURVEY_HOST_SUBDOMAIN}.${SIMVA_INTERNAL_DOMAIN}"

##############
# Minio info #
##############
export SIMVA_MINIO_IDENTITY_OPENID_SCOPES="openid,policy_role_attribute"

##############
# Kafka info #
##############
export SIMVA_KAFKA_NETWORK="kafka_services"
export SIMVA_TRACES_BUCKET_NAME="traces"
export SIMVA_SINK_TOPICS_DIR="kafka-topics"
export SIMVA_TRACES_TOPIC="traces"
export SIMVA_SINK_USERS_DIR="users"
export SIMVA_SINK_TRACES_FILE="traces.json"
export SIMVA_TRACES_FLUSH_SIZE=500

#####################
# Analytics A2 info #
#####################
export SIMVA_A2_HOST="a2"
export SIMVA_A2_ANALYTICSBACKEND_API="/api/proxy/gleaner"

#######################
# SIMVA MONGO DB INFO #
#######################
export SIMVA_API_MONGO_DB="/simva"
export SIMVA_API_LTI_MONGO_DB="/lti_simva"
export SIMVA_FRONT_MONGO_DB="/simva-front"

##############
# SIMVA INFO #
##############
export SIMVA_SCRIPT_WAIT_TIME="10"
export SIMVA_STORAGE_LOCAL_PATH="/storage"
export SIMVA_SSO_USER_CAN_SELECT_ROLE="true"
export SIMVA_SSO_ADMINISTRATOR_CONTACT="contact@administrator.com"

export SIMVA_LTI_ENABLED="false"

##############################
# SIMVA Trace Allocator INFO #
##############################
export SIMVA_TRACE_ALLOCATOR_BATCH_SIZE="100"
export SIMVA_TRACE_ALLOCATOR_MAX_DELAY="300000" #5 mins in ms - 5*60*1000 = 300.000 ms
export SIMVA_TRACE_ALLOCATOR_REFRESH_INTERVAL="14400000" #4 hours in ms -4*60*60*1000 = 14.400.000 ms
export SIMVA_TRACE_ALLOCATOR_LOCAL_STATE="/data"
export SIMVA_TRACE_ALLOCATOR_REMOTE_STATE="state"
export SIMVA_TRACE_ALLOCATOR_REMOVE_DRY_RUN="false"
export SIMVA_TRACE_ALLOCATOR_GC_INTERVAL="864000000" #10 days in ms - 10*24*60*60*10000 = 864.000.000 ms
export SIMVA_TRACE_ALLOCATOR_COPY_INSTEAD_RENAME="true"
export SIMVA_TRACE_ALLOCATOR_TRY_RECOVERY="true"

####################################################################
######## Authentification username and password (TO MODIFY) ########
####################################################################
# Traefik dashboard is protected using basic authentication
export SIMVA_TRAEFIK_DASHBOARD_USER="admin"
export SIMVA_TRAEFIK_DASHBOARD_PASSWORD="password"

# TRUSTSTORE PASSWORD
export SIMVA_TRUSTSTORE_PASSWORD='changeit'

# Keycloak mariadb MySQL database root and keycloak user
export SIMVA_KEYCLOAK_MYSQL_ROOT_PASSWORD="root"
export SIMVA_KEYCLOAK_MYSQL_USER="keycloak"
export SIMVA_KEYCLOAK_MYSQL_PASSWORD="password"

# Keycloak master realm default user
export SIMVA_KEYCLOAK_ADMIN_USER="admin"
export SIMVA_KEYCLOAK_ADMIN_PASSWORD="password"

# Mail Authentification
export SIMVA_MAIL_AUTH="false"
export SIMVA_MAIL_USER="user"
export SIMVA_MAIL_PASSWORD="password"

#Limesurvey default administrator
export SIMVA_LIMESURVEY_ADMIN_USER="admin"
export SIMVA_LIMESURVEY_ADMIN_PASSWORD="password2"

#Limesurvey MySQL default root user and limesurvey user
export SIMVA_LIMESURVEY_MYSQL_ROOT_PASSWORD="root"
export SIMVA_LIMESURVEY_MYSQL_USER="limesurvey"
export SIMVA_LIMESURVEY_MYSQL_PASSWORD="password"

#Limesurvey default administrator
export SIMVA_LIMESURVEY_SIMPLESAMLPHP_ADMIN_PASSWORD="password"

#Minio default administrator
export SIMVA_MINIO_ACCESS_KEY="minio"
export SIMVA_MINIO_SECRET_KEY="password"

#Minio MC default user
export SIMVA_MINIO_MCS_USER="mcs"
export SIMVA_MINIO_MCS_SECRET="password"

export SIMVA_MCS_HMAC_JWT_SECRET="YOURJWTSIGNINGSECRET"
#required to encrypt jwet payload
export SIMVA_MCS_PBKDF_PASSPHRASE="SECRET"
#required to encrypt jwet payload
export SIMVA_MCS_PBKDF_SALT="SECRET"

export SIMVA_KAFKA_CONNECT_SINK_USER="simva-sink"
export SIMVA_KAFKA_CONNECT_SINK_SECRET="password"

# SIMVA API default user
export SIMVA_API_ADMIN_USERNAME="admin"
export SIMVA_API_ADMIN_PASSWORD="password"

#A2 Password
export SIMVA_A2_ADMIN_USER="root"
export SIMVA_A2_ADMIN_PASSWORD="password"

#SIMVA LTI plateform DB
export SIMVA_LTI_PLATFORM_DB_USER="root"
export SIMVA_LTI_PLATFORM_DB_PASSWORD="password"

#Jupyter Password
export SIMVA_JUPYTER_PASSWORD="password"

# Portainer admin password
export SIMVA_PORTAINER_ADMIN_PASSWORD="password"

# DOZZLE
export SIMVA_DOZZLE_USERNAME="simva"
export SIMVA_DOZZLE_PASSWORD="password"

####################################################################
# ######################### KEYCLOAK USERS #########################
# ACCESS_KEY AND SECRET_KEY VARIABLES FOR KEYCLOAK CLIENTS CREATION
####################################################################
# SIMVA ACCESS_KEY AND SECRET_KEY FOR KEYCLOAK
export SIMVA_SIMVA_CLIENT_ID="simva"
export SIMVA_SIMVA_CLIENT_SECRET="secret"

# LTI PLATFORM ACCESS_KEY AND SECRET_KEY FOR KEYCLOAK
export SIMVA_LTI_PLATFORM_CLIENT_ID="lti_platform"
export SIMVA_LTI_PLATFORM_CLIENT_SECRET="secret"

########################################################
# Uncomment client secret if you want to set up for those client
# else it is generated automatically by script
########################################################
# LIMESURVEY ACCESS_KEY AND SECRET_KEY FOR KEYCLOAK
export SIMVA_LIMESURVEY_CLIENT_ID="limesurvey"
#export SIMVA_LIMESURVEY_CLIENT_SECRET="secret"

# MINIO ACCESS_KEY AND SECRET_KEY FOR KEYCLOAK
export SIMVA_MINIO_CLIENT_ID="minio"
#export SIMVA_MINIO_CLIENT_SECRET="secret"

# Jupyter ACCESS_KEY AND SECRET_KEY FOR KEYCLOAK
export SIMVA_JUPYTER_CLIENT_ID="jupyter"
#export SIMVA_JUPYTER_CLIENT_SECRET="secret"

####################################################################
# USERNAME AND PASSWORD VARIABLES FOR KEYCLOAK USER CREATION 
####################################################################
# Administrator Username and password FOR KEYCLOAK
export SIMVA_ADMINISTRATOR_USER="administrator"
export SIMVA_ADMINISTRATOR_PASSWORD="administrator"

########################################################
# Uncomment password if you want to set up for those template users
# else it is generated automatically by script
########################################################
# Template Student Username and password FOR KEYCLOAK
export SIMVA_STUDENT_ALLOWED_ROLE="true"
export SIMVA_STUDENT_USER="student"
#export SIMVA_STUDENT_PASSWORD="password"

# Template teaching-assistant Username and password FOR KEYCLOAK
export SIMVA_TEACHING_ASSISTANT_ALLOWED_ROLE="true"
export SIMVA_TEACHING_ASSISTANT_USER="teaching-assistant" 
#export SIMVA_TEACHING_ASSISTANT_PASSWORD="password" 

# Template teacher Username and password FOR KEYCLOAK
export SIMVA_TEACHER_ALLOWED_ROLE="true"
export SIMVA_TEACHER_USER="teacher"
#export SIMVA_TEACHER_PASSWORD="password"

# Template researcher Username and password FOR KEYCLOAK
export SIMVA_RESEARCHER_ALLOWED_ROLE="true"
export SIMVA_RESEARCHER_USER="researcher"
#export SIMVA_RESEARCHER_PASSWORD="password"
########################################################

