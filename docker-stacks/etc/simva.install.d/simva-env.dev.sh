#!/usr/bin/env bash

###################
# Images versions #
###################
# Nginx versions
export SIMVA_NGINX_IMAGE="nginx"
export SIMVA_NGINX_VERSION="1.19.2" #"1.31.8"

# Whoami image
export SIMVA_WHOAMI_IMAGE="containous/whoami"
export SIMVA_WHOAMI_VERSION="v1.5.0"

# Node image for CSP Reporter 
export SIMVA_NODE_IMAGE="node"
export SIMVA_NODE_VERSION="12.18.2"

# Mail Dev image
export SIMVA_MAILDEV_IMAGE="maildev/maildev"
export SIMVA_MAILDEV_VERSION="3.0.0"

# PHPMyAdmin image
export SIMVA_PHPMYADMIN_IMAGE="phpmyadmin/phpmyadmin"
export SIMVA_PHPMYADMIN_VERSION="5.2.3"

# Kafka images
export SIMVA_KAFKA_SCHEMA_REGISTRY_IMAGE="confluentinc/cp-schema-registry"
export SIMVA_KAFKA_REST_IMAGE="confluentinc/cp-kafka-rest"

# Kafka UI image
export SIMVA_KAKFA_UI_IMAGE="provectuslabs/kafka-ui"
export SIMVA_KAKFA_UI_VERSION="v0.7.2"

#SHLINK ADMIN IMAGE
export SIMVA_SHLINK_ADMIN_IMAGE="ghcr.io/shlinkio/shlink-web-client"
export SIMVA_SHLINK_ADMIN_VERSION="4.8.1"

# Mongoku image
export SIMVA_MONGOKU_UI_IMAGE="huggingface/mongoku"
export SIMVA_MONGOKU_UI_VERSION="2.11.3"

# Portainer image
export SIMVA_PORTAINER_IMAGE="portainer/portainer-ce"
export SIMVA_PORTAINER_VERSION="2.45.3"

########################
# SIMVA Git repository #
########################
# The folders are declared in simva-env.sh so they are available in every environment, only the
# base is overridden here when deploying local code instead of the checked out sources.
base_for_simva_repos="${SIMVA_DATA_HOME}/simva"
base_for_limesurvey_repos="${SIMVA_DATA_HOME}/limesurvey"
base_for_tmon_repos="${SIMVA_DATA_HOME}/tmon"
if [[ $SIMVA_DEVELOPMENT_LOCAL == "true" ]]; then
    base_for_simva_repos="${SIMVA_HOME}/../.."
    base_for_limesurvey_repos="${SIMVA_HOME}/../.."
    base_for_tmon_repos="${SIMVA_HOME}/../.."
    export SIMVA_API_GIT_REPO="${base_for_simva_repos}/simva"
fi
export SIMVA_FRONT_GIT_REPO="${base_for_simva_repos}/simva-front"
export SIMVA_TRACE_ALLOCATOR_GIT_REPO="${base_for_simva_repos}/simva-trace-allocator"
export SIMVA_PUMVA_GIT_REPO="${base_for_simva_repos}/pumva"
export SIMVA_PUMVA_FRONT_GIT_REPO="${base_for_simva_repos}/pumva-front"
export SIMVA_LIMESURVEY_DOCKER_GIT_REPO="${base_for_limesurvey_repos}/docker-limesurvey"
export SIMVA_TMON_GIT_REPO="${base_for_tmon_repos}/t-mon"
export SIMVA_KEYCLOAK_EXTENSIONS_LOCAL_PATH="${SIMVA_HOME}/../../keycloak-extensions"
export SIMVA_KAFKA_EXTENSIONS_LOCAL_PATH="${SIMVA_HOME}/../../kafka-extensions"
export SIMVA_LIMESURVEY_PLUGINS_LOCAL_PATH="${SIMVA_HOME}/../.."
export SIMVA_JSTRACKER_LIBRARY_LOCAL_PATH="${SIMVA_HOME}/../../js-tracker"

###########################
# SIMVA Load Balancer IPs #
###########################
[[ "${SIMVA_DEV_LOAD_BALANCER}" == "true" ]] && export SIMVA_LOAD_BALANCER_IPS=$SIMVA_DEV_LOAD_BALANCER_IPS
[[ "${SIMVA_LOAD_BALANCER}" == "true" ]] && export SIMVA_LOAD_BALANCER_IPS=$SIMVA_LOAD_BALANCER_IPS


################
# Traefik info #
################
[[ "${SIMVA_ENVIRONMENT}" == "development" ]] && SIMVA_TRAEFIK_EXTRA_CSP_POLICY=" report-uri https://${SIMVA_CSP_REPORTER_HOST_SUBDOMAIN:-csp-reporter}.${SIMVA_EXTERNAL_DOMAIN}/report-violation; report-to https://${SIMVA_CSP_REPORTER_HOST_SUBDOMAIN:-csp-reporter}.${SIMVA_EXTERNAL_DOMAIN}/report-violation;"