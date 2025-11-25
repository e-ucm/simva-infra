################
# SIMVA STACKS #
################
export SIMVA_STACKS="00-network 01-traefik 02-keycloak 03-limesurvey 04-minio 05-kafka 06-shlink 07-simva 08-anaconda 09-logs"

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

#################
# DOCKER Images #
#################
# Images versions
#TRAEFIK
export SIMVA_TRAEFIK_IMAGE="traefik"
export SIMVA_TRAEFIK_VERSION="2.11.3"

#KEYCLOAK SSO
export SIMVA_KEYCLOAK_IMAGE="quay.io/keycloak/keycloak"
export SIMVA_KEYCLOAK_VERSION="26.1.3"

#SQL DB
export SIMVA_MARIADB_IMAGE="mariadb"
export SIMVA_MARIADB_VERSION="10.4.13"

#LIMESURVEY
export SIMVA_LIMESURVEY_IMAGE="eucm/limesurvey"
export SIMVA_LIMESURVEY_VERSION="4.3.15-4"

#MINIO
export SIMVA_MINIO_IMAGE="minio/minio"
export SIMVA_MINIO_VERSION="RELEASE.2025-02-28T09-55-16Z"
export SIMVA_MINIO_MC_IMAGE="minio/mc"
export SIMVA_MINIO_MC_VERSION="RELEASE.2025-02-04T04-57-50Z"

#KAFKA
export SIMVA_KAFKA_IMAGE="confluentinc/cp-kafka"
export SIMVA_KAFKA_VERSION="7.8.0"
#KAFKA CONNECT AND CONNECT S3 PLUGIN
export SIMVA_KAFKA_CONNECT_IMAGE="cnfldemos/kafka-connect-datagen"
export SIMVA_KAFKA_CONNECT_VERSION="0.6.7-8.0.0" #0.6.4-7.6.0
export SIMVA_CONFLUENCE_CONNECT_S3_REPO="confluentinc/kafka-connect-s3"
export SIMVA_CONFLUENCE_CONNECT_S3_VERSION="11.0.1"

#SIMVA
export SIMVA_SIMVA_IMAGE="eucm/simva-api"
export SIMVA_SIMVA_VERSION="0.0.1"
export SIMVA_SIMVA_TRACE_ALLOCATOR_IMAGE="eucm/simva-trace-allocator"
export SIMVA_SIMVA_TRACE_ALLOCATOR_VERSION="0.0.1"
export SIMVA_SIMVA_FRONT_IMAGE="eucm/simva-front"
export SIMVA_SIMVA_FRONT_VERSION="0.0.1"
#NO SQL DB
export SIMVA_MONGODB_IMAGE="mongo"
export SIMVA_MONGODB_VERSION="4.2.8"

#LOGS
export SIMVA_LOGS_IMAGE="amir20/dozzle"
export SIMVA_LOGS_VERSION="8.10.3"

#Git reference tag version release branch
export SIMVA_KEYCLOAK_EXTENSIONS_VERSION="1.2.0"
export SIMVA_KEYCLOAK_EVENT_EXTENSION_VERSION="0.26"
export SIMVA_KAFKA_EXTENSIONS_VERSION="1.0.0"

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