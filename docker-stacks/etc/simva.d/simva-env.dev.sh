#!/usr/bin/env bash
export SIMVA_DEVELOPMENT_LOCAL="false"
export SIMVA_DEBUG="true"

#########################################
# Generate self signed TLS certificates #
#########################################
export SIMVA_TLS_GENERATE_SELF_SIGNED="true"

###########################################
# Images versions and SIMVA Git reference #
###########################################
# Images versions
export SIMVA_NGINX_IMAGE="nginx"
export SIMVA_NGINX_VERSION="1.19.2"

export SIMVA_WHOAMI_IMAGE="containous/whoami"
export SIMVA_WHOAMI_VERSION="latest"

export SIMVA_NODE_IMAGE="node"
export SIMVA_NODE_VERSION="12.18.2"

export SIMVA_MAILDEV_IMAGE="maildev/maildev"
export SIMVA_MAILDEV_VERSION="1.1.0"

export SIMVA_PHPMYADMIN_IMAGE="phpmyadmin/phpmyadmin"
export SIMVA_PHPMYADMIN_VERSION="5.0.2"

export SIMVA_ZOOKEEPER_IMAGE="zookeeper"
export SIMVA_ZOOKEEPER_VERSION="3.4.9"

export SIMVA_KAKFA_UI_IMAGE="provectuslabs/kafka-ui"
export SIMVA_KAKFA_UI_VERSION="latest"

export SIMVA_MONGOKU_UI_IMAGE="huggingface/mongoku"
export SIMVA_MONGOKU_UI_VERSION="latest"

export SIMVA_ANACONDA_IMAGE="continuumio/anaconda3"
export SIMVA_ANACONDA_VERSION="2024.02-1"

export SIMVA_PORTAINER_IMAGE="portainer/portainer-ce"
export SIMVA_PORTAINER_VERSION="latest"

#Git reference branch
export CSP_REPORTER_GIT_REF="master"

branch="dev"
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

# SIMVA Load Balancer IPs
export SIMVA_DEV_LOAD_BALANCER="false"
export SIMVA_LOAD_BALANCER_IPS="172.30.0.80"
[[ "${SIMVA_ENVIRONMENT}" == "production" ]] && SIMVA_LOAD_BALANCER_IPS="127.0.0.1"

########################
# Domain and subdomain #
########################
# Traefik Host
export SIMVA_WHOAMI_HOST_SUBDOMAIN="whoami"
export SIMVA_NGINX_HOST_SUBDOMAIN="nginx"
export SIMVA_WHOAMI_NGINX_HOST_SUBDOMAIN="nginx-whoami"
export SIMVA_CSP_REPORTER_HOST_SUBDOMAIN="csp-reporter"
#Limesurvey host
export SIMVA_PHPMYADMIN_KC_HOST_SUBDOMAIN="phpmyadmin-kc"
export SIMVA_PHPMYADMIN_LS_HOST_SUBDOMAIN="phpmyadmin-ls"
#KAFKA
export SIMVA_KAFKA_UI_HOST_SUBDOMAIN="kafka-ui"
export SIMVA_ZOONAVIGATOR_HOST_SUBDOMAIN="zoonavigator"
#SIMVA MONGO DB 
export SIMVA_MONGO_UI_HOST_SUBDOMAIN="simva-mongo-ui"
#SHLINK
export SIMVA_SHLINK_ADMIN_HOST_SUBDOMAIN="shlink-admin"
#Jupyter Notebook
export SIMVA_JUPYTER_HOST_SUBDOMAIN="jupyter"
#LOGS
export SIMVA_PORTAINER_HOST_SUBDOMAIN="portainer"

#####################
# Socket Proxy info #
#####################
# tecnativa/socket-proxy logging level, possible values: info, debug
export SIMVA_SOCKET_PROXY_LOG_LEVEL="info"

################
# Traefik info #
################
[[ "${SIMVA_ENVIRONMENT}" == "development" ]] && SIMVA_TRAEFIK_EXTRA_CSP_POLICY=" report-uri https://${SIMVA_CSP_REPORTER_HOST_SUBDOMAIN:-csp-reporter}.${SIMVA_EXTERNAL_DOMAIN}/report-violation; report-to https://${SIMVA_CSP_REPORTER_HOST_SUBDOMAIN:-csp-reporter}.${SIMVA_EXTERNAL_DOMAIN}/report-violation;"

####################################################################
######## Authentification username and password (TO MODIFY) ########
####################################################################
#Jupyter Password
export SIMVA_JUPYTER_PASSWORD="password"

# Portainer admin password
export SIMVA_PORTAINER_ADMIN_PASSWORD="password"


