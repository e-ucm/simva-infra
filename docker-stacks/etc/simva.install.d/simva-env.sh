#!/usr/bin/env bash
################
# SIMVA STACKS #
################
export SIMVA_STACKS="00-network 01-traefik 02-keycloak 03-limesurvey 04-minio 05-kafka 06-shlink 07-simva 08-tmon 09-logs"

#############################
# SIMVA installation folder #
#############################
export SIMVA_HOME="${SIMVA_PROJECT_DIR}"

export SIMVA_BIN_HOME="${SIMVA_HOME}/bin"

export SIMVA_BACKUP_HOME="${SIMVA_HOME}/backup"

export SIMVA_DATA_HOME="${SIMVA_HOME}/data"

export SIMVA_CONFIG_HOME="${SIMVA_HOME}/config"

export SIMVA_CONFIG_TEMPLATE_HOME="${SIMVA_HOME}/config-template"

export SIMVA_ETC_HOME="${SIMVA_HOME}/etc"

export SIMVA_TLS_HOME="${SIMVA_CONFIG_HOME}/tls"

export SIMVA_CONTAINER_TOOLS_HOME="${SIMVA_CONFIG_HOME}/container-tools"

##############################
# DOCKER Images AND SETTINGS #
##############################
# Images versions
#TRAEFIK IMAGE
export SIMVA_TRAEFIK_IMAGE="traefik"
export SIMVA_TRAEFIK_VERSION="2.11.3"
#TRAEFIK SETTINGS
export SIMVA_TRAEFIK_GUID="root" #root
export SIMVA_TRAEFIK_UUID="root" #root
export SIMVA_TRAEFIK_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_TRAEFIK_DIR_MODE="755" #rwxr-xr-x
export SIMVA_TRAEFIK_FILE_MODE="644" #rw-r--r--

#KEYCLOAK SSO IMAGE
export SIMVA_KEYCLOAK_IMAGE="quay.io/keycloak/keycloak"
export SIMVA_KEYCLOAK_VERSION="26.1.3"
#KEYCLOAK SETTINGS
export SIMVA_KEYCLOAK_GUID="root" #root
export SIMVA_KEYCLOAK_UUID="root" #root
export SIMVA_KEYCLOAK_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_KEYCLOAK_DIR_MODE="755" #rwxr-xr-x
export SIMVA_KEYCLOAK_FILE_MODE="644" #rw-r--r--

#SQL DB IMAGE
export SIMVA_MARIADB_IMAGE="mariadb"
export SIMVA_MARIADB_VERSION="10.4.13"
#MARIADB SETTINGS
export SIMVA_MARIA_DB_GUID="999" #mysql
export SIMVA_MARIA_DB_UUID="ping" #mysql
export SIMVA_MARIA_DB_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_MARIA_DB_DIR_MODE="700" #rwx------
export SIMVA_MARIA_DB_FILE_MODE="660" #rw-rw----
#MARIADB SETTINGS FOR BACKUP DATA
export SIMVA_MARIA_DB_BACKUP_GUID="root" #root
export SIMVA_MARIA_DB_BACKUP_UUID="root" #root
export SIMVA_MARIA_DB_BACKUP_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_MARIA_DB_BACKUP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_MARIA_DB_BACKUP_FILE_MODE="644" #rw-r--r--

#LIMESURVEY IMAGE
export SIMVA_LIMESURVEY_IMAGE="martialblog/limesurvey"
export SIMVA_LIMESURVEY_VERSION="6-apache"
#LIMESURVEY SETTINGS
export SIMVA_LIMESURVEY_GUID="33" #wwww-data
export SIMVA_LIMESURVEY_UUID="33" #wwww-data
export SIMVA_LIMESURVEY_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_LIMESURVEY_DIR_MODE="755" #rwxr-xr-x
export SIMVA_LIMESURVEY_FILE_MODE="644" #rw-r--r--

#MINIO IMAGE
export SIMVA_MINIO_IMAGE="minio/minio"
export SIMVA_MINIO_VERSION="RELEASE.2025-02-28T09-55-16Z"
export SIMVA_MINIO_MC_IMAGE="minio/mc"
export SIMVA_MINIO_MC_VERSION="RELEASE.2025-02-04T04-57-50Z"
#MINIO SETTINGS
export SIMVA_MINIO_GUID="1000" #1000
export SIMVA_MINIO_UUID="1000" #1000
export SIMVA_MINIO_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_MINIO_DIR_MODE="755" #rwxr-xr-x
export SIMVA_MINIO_FILE_MODE="644" #rw-r--r--

#KAFKA IMAGE
export SIMVA_KAFKA_IMAGE="confluentinc/cp-kafka"
export SIMVA_KAFKA_CONNECT_IMAGE="confluentinc/cp-kafka-connect-base"
export SIMVA_KAFKA_VERSION="7.8.0"
#KAFKA SETTINGS
export SIMVA_KAFKA_GUID="1000" #appuser
export SIMVA_KAFKA_UUID="1000" #appuser 
export SIMVA_KAKFKA_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_KAKFKA_DIR_MODE="755" #rwxr-xr-x
export SIMVA_KAKFKA_FILE_MODE="644" #rw-r--r--

#SHLINK IMAGE
export SIMVA_SHLINK_IMAGE="ghcr.io/shlinkio/shlink"
export SIMVA_SHLINK_VERSION="stable"
#SHLINK SETTINGS
export SIMVA_SHLINK_GUID="1001" #1001
export SIMVA_SHLINK_UUID="1001" #1001
export SIMVA_SHLINK_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_SHLINK_DIR_MODE="755" #rwxr-xr-x
export SIMVA_SHLINK_FILE_MODE="644" #rw-r--r--

#SIMVA IMAGE
export SIMVA_NODE_GUID="1000" #node
export SIMVA_NODE_UUID="1000" #node
export SIMVA_NODE_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_NODE_DIR_MODE="755" #rwxr-xr-x
export SIMVA_NODE_FILE_MODE="644" #rw-r--r--

#SIMVA API IMAGE
export SIMVA_SIMVA_IMAGE="eucm/simva-api"
export SIMVA_SIMVA_VERSION="0.0.1"
#SIMVA API SETTINGS
export SIMVA_SIMVA_GUID=$SIMVA_NODE_GUID
export SIMVA_SIMVA_UUID=$SIMVA_NODE_UUID
export SIMVA_SIMVA_TOP_DIR_MODE=$SIMVA_NODE_TOP_DIR_MODE
export SIMVA_SIMVA_DIR_MODE=$SIMVA_NODE_DIR_MODE
export SIMVA_SIMVA_FILE_MODE=$SIMVA_NODE_FILE_MODE

# SIMVA TRACE ALLOCATOR IMAGE
export SIMVA_SIMVA_TRACE_ALLOCATOR_IMAGE="eucm/simva-trace-allocator"
export SIMVA_SIMVA_TRACE_ALLOCATOR_VERSION="0.0.1"
# SIMVA TRACE ALLOCATOR SETTINGS
export SIMVA_SIMVA_TRACE_ALLOCATOR_GUID=$SIMVA_NODE_GUID
export SIMVA_SIMVA_TRACE_ALLOCATOR_UUID=$SIMVA_NODE_UUID 
export SIMVA_SIMVA_TRACE_ALLOCATOR_TOP_DIR_MODE=$SIMVA_NODE_TOP_DIR_MODE
export SIMVA_SIMVA_TRACE_ALLOCATOR_DIR_MODE=$SIMVA_NODE_DIR_MODE
export SIMVA_SIMVA_TRACE_ALLOCATOR_FILE_MODE=$SIMVA_NODE_FILE_MODE

# SIMVA FRONT IMAGE
export SIMVA_SIMVA_FRONT_IMAGE="eucm/simva-front"
export SIMVA_SIMVA_FRONT_VERSION="0.0.1"
# SIMVA FRONT SETTINGS
export SIMVA_SIMVA_FRONT_GUID=$SIMVA_NODE_GUID
export SIMVA_SIMVA_FRONT_UUID=$SIMVA_NODE_UUID
export SIMVA_SIMVA_FRONT_TOP_DIR_MODE=$SIMVA_NODE_TOP_DIR_MODE
export SIMVA_SIMVA_FRONT_DIR_MODE=$SIMVA_NODE_DIR_MODE
export SIMVA_SIMVA_FRONT_FILE_MODE=$SIMVA_NODE_FILE_MODE

#NO SQL DB IMAGE
export SIMVA_MONGODB_IMAGE="mongo"
export SIMVA_MONGODB_VERSION="4.2.8"
#MONGODB SETTINGS
export SIMVA_MONGO_DB_GUID="999" #mongodb
export SIMVA_MONGO_DB_UUID="999" #mongodb
export SIMVA_MONGO_DB_TOP_DIR_MODE="700" #rwx------
export SIMVA_MONGO_DB_DIR_MODE="700" #rwx------
export SIMVA_MONGO_DB_FILE_MODE="600" #rw-------

#TMON IMAGE
export SIMVA_TMON_IMAGE="eucm/t-mon"
export SIMVA_TMON_VERSION="0.0.1"
#TMON SETTINGS
export SIMVA_TMON_GUID="root" #root
export SIMVA_TMON_UUID="root" #root
export SIMVA_TMON_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_TMON_DIR_MODE="755" #rwxr-xr-x
export SIMVA_TMON_FILE_MODE="644" #rw-r--r--

#LOGS IMAGE
export SIMVA_LOGS_IMAGE="amir20/dozzle"
export SIMVA_LOGS_VERSION="8.10.3"
#LOGS SETTINGS
export SIMVA_LOGS_GUID="root" #root
export SIMVA_LOGS_UUID="root" #root
export SIMVA_LOGS_TOP_DIR_MODE="755" #rwxr-xr-x
export SIMVA_LOGS_DIR_MODE="755" #rwxr-xr-x
export SIMVA_LOGS_FILE_MODE="644" #rw-r--r--

##########################
# Extensions and Plugins #
##########################
#Git reference tag version release branch for Keycloak Extensions
export SIMVA_KEYCLOAK_EXTENSIONS_VERSION="1.2.0"
export SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION="0.26"

#Git reference tag version release branch for Kafka Extensions
export SIMVA_KAFKA_EXTENSIONS_VERSION="1.0.0"

#KAFKA CONNECT S3 PLUGIN
export SIMVA_CONFLUENCE_CONNECT_S3_REPO="confluentinc/kafka-connect-s3"
export SIMVA_CONFLUENCE_CONNECT_S3_VERSION="11.0.1"

#Git reference tag version release branch for Limesurvey Plugins
export SIMVA_LIMESURVEY_AUTHOAUTH2_PLUGIN_VERSION="1.5.0"
export SIMVA_LIMESURVEY_WEBHOOK_PLUGIN_VERSION="1.1.0"
export SIMVA_LIMESURVEY_XAPITRACKER_PLUGIN_VERSION="1.0.0"

#################################
# OS and Architecture detection #
#################################
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
if [[ $SIMVA_SHLINK_EXTERNAL_DOMAIN == "" ]]; then 
    export SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN=true
    export SIMVA_SHLINK_EXTERNAL_DOMAIN="${SIMVA_SHLINK_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
else 
    export SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN=false
fi

########################
# Traefik certificates #
########################
# Traefik: list of certificates (as file paths, or data bytes) that will be set as Root Certificate
# Authorities when using a self-signed TLS certificate
# example: foo.crt,bar.crt
export SIMVA_CERT_FILE_MOD="644" #rw-r--r--
export SIMVA_SSL_ROOT_CAS_FILENAME="isrgrootx1.pem"
export SIMVA_ROOT_CA_FILENAME="rootCA.pem"
export SIMVA_ROOT_CA_KEY_FILENAME="rootCA-key.pem"

export SIMVA_DHPARAM_FILENAME="dhparam.pem"
export SIMVA_TRUSTSTORE_FILENAME="truststore.jks"

export SIMVA_TRAEFIK_FULLCHAIN_CERT_FILENAME="traefik-fullchain.pem"
export SIMVA_TRAEFIK_KEY_FILENAME="traefik-key.pem"
export SIMVA_TRAEFIK_CERT_FILENAME="traefik.pem"

export SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILENAME="traefik-shlink-fullchain.pem"
export SIMVA_TRAEFIK_SHLINK_KEY_FILENAME="traefik-shlink-key.pem"
export SIMVA_TRAEFIK_SHLINK_CERT_FILENAME="traefik-shlink.pem"
export SIMVA_TRUSTSTORE_SHLINK_FILENAME="truststore-shlink.jks"

export SIMVA_ROOT_CA="${SIMVA_TLS_HOME}/ca"
export SIMVA_SSL_ROOT_CAS="${SIMVA_ROOT_CA}/${SIMVA_SSL_ROOT_CAS_FILENAME}"
export SIMVA_ROOT_CA_FILE="${SIMVA_ROOT_CA}/${SIMVA_ROOT_CA_FILENAME}"
export SIMVA_ROOT_CA_KEY_FILE="${SIMVA_ROOT_CA}/${SIMVA_ROOT_CA_KEY_FILENAME}"
export SIMVA_ROOT_CA_BACKUP_FILE="${SIMVA_ROOT_CA}/backup/${SIMVA_ROOT_CA_FILENAME}"
export SIMVA_ROOT_CA_KEY_BACKUP_FILE="${SIMVA_ROOT_CA}/backup/${SIMVA_ROOT_CA_KEY_FILENAME}"

export SIMVA_DHPARAM_FILE="${SIMVA_TLS_HOME}/${SIMVA_DHPARAM_FILENAME}"
export SIMVA_TRUSTSTORE_FILE="${SIMVA_TLS_HOME}/${SIMVA_TRUSTSTORE_FILENAME}"

export SIMVA_TRAEFIK_FULLCHAIN_CERT_FILE="${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_FULLCHAIN_CERT_FILENAME}"
export SIMVA_TRAEFIK_KEY_FILE="${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_KEY_FILENAME}"
export SIMVA_TRAEFIK_CERT_FILE="${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_CERT_FILENAME}"

export SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILE="${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_SHLINK_FULLCHAIN_CERT_FILENAME}"
export SIMVA_TRAEFIK_SHLINK_KEY_FILE="${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_SHLINK_KEY_FILENAME}"
export SIMVA_TRAEFIK_SHLINK_CERT_FILE="${SIMVA_TLS_HOME}/${SIMVA_TRAEFIK_SHLINK_CERT_FILENAME}"
export SIMVA_TRUSTSTORE_SHLINK_FILE="${SIMVA_TLS_HOME}/${SIMVA_TRUSTSTORE_SHLINK_FILENAME}"

export SIMVA_SHA256SUMS_TLS_HOME="${SIMVA_TLS_HOME}/sha256sums"
export SIMVA_ROOTCA_SHA256SUMS_FILE="${SIMVA_SHA256SUMS_TLS_HOME}/rootca-sha256sums"
export SIMVA_TRAEFIK_SHA256SUMS_FILE="${SIMVA_SHA256SUMS_TLS_HOME}/traefik-sha256sums"
export SIMVA_TRAEFIK_FULLCHAIN_SHA256SUMS_FILE="${SIMVA_SHA256SUMS_TLS_HOME}/traefik-fullchain-sha256sums"
export SIMVA_TRAEFIK_SHLINK_SHA256SUMS_FILE="${SIMVA_SHA256SUMS_TLS_HOME}/traefik-shlink-sha256sums"
export SIMVA_TRAEFIK_SHLINK_FULLCHAIN_SHA256SUMS_FILE="${SIMVA_SHA256SUMS_TLS_HOME}/traefik-shlink-fullchain-sha256sums"

#########################
# Keycloak certificates #
#########################
export SIMVA_KEYCLOAK_TMP_ADMIN_USER="admin_tmp"
# Keycloak: list of certificates (as file paths, or data bytes) that will be set as Root Certificate
# Authorities when using a self-signed TLS certificate
# example: foo.crt,bar.crt
export SIMVA_KEYCLOAK_CERT_FILENAME="keycloak.p12"
export SIMVA_KEYCLOAK_CERT_FILE="${SIMVA_TLS_HOME}/${SIMVA_KEYCLOAK_CERT_FILENAME}"

###########################
# Limesurvey certificates #
###########################
# Limesurvey: list of certificates (as file paths, or data bytes) that will be set as Root Certificate
# Authorities when using a self-signed TLS certificate
# example: foo.crt,bar.crt
export SIMVA_LIMESURVEY_FULLCHAIN_CERT_FILENAME="limesurvey-fullchain.pem"
export SIMVA_LIMESURVEY_KEY_FILENAME="limesurvey-key.pem"
export SIMVA_LIMESURVEY_CERT_FILENAME="limesurvey.pem"
export SIMVA_LIMESURVEY_CERT_CRS_FILENAME="limesurvey.csr"
export SIMVA_LIMESURVEY_FULLCHAIN_CERT_FILE="${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_FULLCHAIN_CERT_FILENAME}"
export SIMVA_LIMESURVEY_KEY_FILE="${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_KEY_FILENAME}"
export SIMVA_LIMESURVEY_CERT_FILE="${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_CERT_FILENAME}"
export SIMVA_LIMESURVEY_CERT_CRS_FILE="${SIMVA_TLS_HOME}/${SIMVA_LIMESURVEY_CERT_CRS_FILENAME}"

##########################################
# Checking time for container availabled #
##########################################
#Checking time and max retries in second for containers availabled
export SIMVA_WAIT_TIMEOUT="120"
export SIMVA_WAIT_TIME="15"
export SIMVA_MAX_RETRIES="20"


##############
# SIMVA INFO #
##############
export SIMVA_SCRIPT_WAIT_TIME="10"