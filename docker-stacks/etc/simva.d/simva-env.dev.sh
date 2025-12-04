#!/usr/bin/env bash
###############
# SIMVA DEBUG #
###############
export SIMVA_DEBUG="true"

###########################
# SIMVA LOCAL DEVELOPMENT #
###########################
export SIMVA_DEVELOPMENT_LOCAL="false"

###########################
# SIMVA Load Balancer IPs #
###########################
export SIMVA_DEV_LOAD_BALANCER="false"
export SIMVA_DEV_LOAD_BALANCER_IPS="172.30.0.80"

########################
# Domain and subdomain #
########################
# Traefik Host
export SIMVA_WHOAMI_HOST_SUBDOMAIN="whoami"
export SIMVA_NGINX_HOST_SUBDOMAIN="nginx"
export SIMVA_WHOAMI_NGINX_HOST_SUBDOMAIN="nginx-whoami"
export SIMVA_CSP_REPORTER_HOST_SUBDOMAIN="csp-reporter"
#PHPMYADMIN host for Keycloak and Limesurvey
export SIMVA_PHPMYADMIN_HOST_SUBDOMAIN="phpmyadmin"
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

#######################
# SIMVA Git reference #
#######################
#Git reference branch
export CSP_REPORTER_GIT_REF="master"
branch="dev"
export SIMVA_API_GIT_REF=$branch
export SIMVA_FRONT_GIT_REF=$branch
export SIMVA_TRACE_ALLOCATOR_GIT_REF=$branch
export SIMVA_LIMESURVEY_DOCKER_GIT_REF="remotecontrol-patch"
export SIMVA_TMON_GIT_REF="plotly-dash"
export SIMVA_TMON_ANACONDA_GIT_REF="master-jupyter-notebook"

#####################
# Socket Proxy info #
#####################
# tecnativa/socket-proxy logging level, possible values: info, debug
export SIMVA_SOCKET_PROXY_LOG_LEVEL="info"

########################
# Profiling Node Debug #
########################
export SIMVA_ENABLE_DEBUG_PROFILING="false"
#doctor, flame, bubbleprof, heapprofiler
export SIMVA_CLINIC_APP="doctor"
#timeout : s - seconds (default) / m - minutes / h - hours / d - days
export SIMVA_CLINIC_TIMEOUT_TIME="20m"

####################################################################
######## Authentification username and password (TO MODIFY) ########
####################################################################
#Jupyter Password
export SIMVA_JUPYTER_PASSWORD="password"

# Portainer admin password
export SIMVA_PORTAINER_ADMIN_PASSWORD="password1234"


