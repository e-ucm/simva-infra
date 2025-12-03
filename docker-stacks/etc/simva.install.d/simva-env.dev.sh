#!/usr/bin/env bash

###################
# Images versions #
###################
# Nginx versions
export SIMVA_NGINX_IMAGE="nginx"
export SIMVA_NGINX_VERSION="1.19.2"

# Whoami image
export SIMVA_WHOAMI_IMAGE="containous/whoami"
export SIMVA_WHOAMI_VERSION="latest"

# Node image for CSP Reporter 
export SIMVA_NODE_IMAGE="node"
export SIMVA_NODE_VERSION="12.18.2"

# Mail Dev image
export SIMVA_MAILDEV_IMAGE="maildev/maildev"
export SIMVA_MAILDEV_VERSION="1.1.0"

# PHPMyAdmin image
export SIMVA_PHPMYADMIN_IMAGE="phpmyadmin/phpmyadmin"
export SIMVA_PHPMYADMIN_VERSION="5.0.2"

# Kafka images
export SIMVA_KAFKA_SCHEMA_REGISTRY_IMAGE="confluentinc/cp-schema-registry"
export SIMVA_KAFKA_REST_IMAGE="confluentinc/cp-kafka-rest"

# Kafka UI image
export SIMVA_KAKFA_UI_IMAGE="provectuslabs/kafka-ui"
export SIMVA_KAKFA_UI_VERSION="latest"

#SHLINK ADMIN IMAGE
export SIMVA_SHLINK_ADMIN_IMAGE="ghcr.io/shlinkio/shlink-web-client"
export SIMVA_SHLINK_ADMIN_VERSION="latest"

# Mongoku image
export SIMVA_MONGOKU_UI_IMAGE="huggingface/mongoku"
export SIMVA_MONGOKU_UI_VERSION="latest"

# Anaconda Jupyter image
export SIMVA_ANACONDA_IMAGE="continuumio/anaconda3"
export SIMVA_ANACONDA_VERSION="2024.02-1"
# Anaconda Jupyter SETTINGS
export SIMVA_JUPYTER_GUID="anaconda" #anaconda
export SIMVA_JUPYTER_UUID="anaconda" #anaconda
export SIMVA_JUPYTER_TOP_DIR_MODE="700" #rwx------
export SIMVA_JUPYTER_DIR_MODE="700" #rwx------
export SIMVA_JUPYTER_FILE_MODE="600" #rw-------

# Portainer image
export SIMVA_PORTAINER_IMAGE="portainer/portainer-ce"
export SIMVA_PORTAINER_VERSION="latest"

########################
# SIMVA Git repository #
########################
base_for_simva_repos="${SIMVA_DATA_HOME}/simva"
[[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]] && base_for_simva_repos="${SIMVA_HOME}/../.."
if [[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]]; then
    export SIMVA_API_GIT_REPO="${base_for_simva_repos}/simva"
else 
    export SIMVA_API_GIT_REPO="${base_for_simva_repos}/simva-api"
fi
export SIMVA_FRONT_GIT_REPO="${base_for_simva_repos}/simva-front"
export SIMVA_TRACE_ALLOCATOR_GIT_REPO="${base_for_simva_repos}/simva-trace-allocator"

base_for_limesurvey_repos="${SIMVA_DATA_HOME}/limesurvey"
[[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]] && base_for_limesurvey_repos="${SIMVA_HOME}/../.."
export SIMVA_LIMESURVEY_DOCKER_GIT_REPO="${base_for_limesurvey_repos}/docker-limesurvey"
base_for_tmon_repos="${SIMVA_DATA_HOME}/tmon"
[[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]] && base_for_tmon_repos="${SIMVA_HOME}/../.."
export SIMVA_TMON_GIT_REPO="${base_for_tmon_repos}/t-mon"

###########################
# SIMVA Load Balancer IPs #
###########################
[[ "${SIMVA_DEV_LOAD_BALANCER}" == "true" ]] && export SIMVA_LOAD_BALANCER_IPS=$SIMVA_DEV_LOAD_BALANCER_IPS
[[ "${SIMVA_LOAD_BALANCER}" == "true" ]] && export SIMVA_LOAD_BALANCER_IPS=$SIMVA_LOAD_BALANCER_IPS


################
# Traefik info #
################
[[ "${SIMVA_ENVIRONMENT}" == "development" ]] && SIMVA_TRAEFIK_EXTRA_CSP_POLICY=" report-uri https://${SIMVA_CSP_REPORTER_HOST_SUBDOMAIN:-csp-reporter}.${SIMVA_EXTERNAL_DOMAIN}/report-violation; report-to https://${SIMVA_CSP_REPORTER_HOST_SUBDOMAIN:-csp-reporter}.${SIMVA_EXTERNAL_DOMAIN}/report-violation;"