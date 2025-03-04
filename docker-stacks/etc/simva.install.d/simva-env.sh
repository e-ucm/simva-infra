################
# SIMVA STACKS #
################
export SIMVA_STACKS="00-network 01-traefik 02-keycloak 03-limesurvey 04-minio 05-kafka 07-simva 08-anaconda 09-logs"

#############################
# SIMVA installation folder #
#############################
export SIMVA_HOME="${SIMVA_PROJECT_DIR}"

export SIMVA_DATA_HOME="${SIMVA_HOME}/data"

export SIMVA_CONFIG_HOME="${SIMVA_HOME}/config"

export SIMVA_CONFIG_TEMPLATE_HOME="${SIMVA_HOME}/config-template"

export SIMVA_TLS_HOME="${SIMVA_CONFIG_HOME}/tls"

export SIMVA_CONTAINER_TOOLS_HOME="${SIMVA_CONFIG_HOME}/container-tools"

#################
# DOCKER Images #
#################
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
export SIMVA_MINIO_VERSION="RELEASE.2025-01-20T14-49-07Z"
export SIMVA_MINIO_MC_IMAGE="minio/mc"
export SIMVA_MINIO_MC_VERSION="RELEASE.2025-02-04T04-57-50Z"

export SIMVA_KAFKA_IMAGE="confluentinc/cp-kafka"
export SIMVA_KAFKA_CONNECT_IMAGE="cnfldemos/kafka-connect-datagen"
export SIMVA_KAFKA_VERSION="7.8.0"

export SIMVA_SIMVA_IMAGE="eucm/simva-api"
export SIMVA_SIMVA_VERSION="0.0.1"
export SIMVA_SIMVA_TRACE_ALLOCATOR_IMAGE="eucm/simva-trace-allocator"
export SIMVA_SIMVA_TRACE_ALLOCATOR_VERSION="0.0.1"
export SIMVA_SIMVA_FRONT_IMAGE="eucm/simva-front"
export SIMVA_SIMVA_FRONT_VERSION="0.0.1"

export SIMVA_MONGODB_IMAGE="mongo"
export SIMVA_MONGODB_VERSION="4.2.8"

export SIMVA_DOZZLE_IMAGE="amir20/dozzle"
export SIMVA_DOZZLE_VERSION="8.10.3"

#Git reference branch
export SIMVA_KEYCLOAK_EVENT_GIT_REF="v0.26"


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
    export SIMVA_SHLINK_EXTERNAL_DOMAIN="${SIMVA_SHLINK_HOST_SUBDOMAIN}.${SIMVA_EXTERNAL_DOMAIN}"
fi


################
# Traefik info #
################
# Traefik: list of certificates (as file paths, or data bytes) that will be set as Root Certificate
# Authorities when using a self-signed TLS certificate
# example: foo.crt,bar.crt
export SIMVA_SSL_ROOT_CAS="${SIMVA_DATA_HOME}/tls/ca/isrgrootx1.pem"

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