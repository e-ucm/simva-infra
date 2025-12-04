#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

: ${RUN_IN_CONTAINER:=false}
: ${RUN_IN_CONTAINER_NAME:=}

_check_docker_running() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    case $run_in_container in
        "true" | 1)
            container=$(echo $(docker compose ps --format '{{.Names}}' | grep "$CURRENT_STACK-$container_name-1"))
            if [[ $container != "" ]]; then
                return 0;
            else 
                return 1;
             fi
            ;;
        *)
            return 1;
            ;;
    esac
}

_start_docker_container() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    case $run_in_container in
        "true" | 1)
            docker compose up -d $container_name
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

_stop_docker_container() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    case $run_in_container in
        "true" | 1)
            docker compose stop $container_name
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

_restart_docker_container() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    case $run_in_container in
        "true" | 1)
            docker compose restart $container_name
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

_copy_to_docker_container() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    path_host=$1
    path_container=$2
    case $run_in_container in
        "true" | 1)
            docker compose cp $path_host $container_name:$path_container
            return 0
            ;;
        *)
            cp $path_host $path_container
            return 0
            ;;
    esac
}

_copy_from_docker_container() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    path_container=$1
    path_host=$2
    
    case $run_in_container in
        "true" | 1)
            docker compose cp $container_name:$path_container $path_host 
            return 0
            ;;
        *)
            cp $path_container $path_host
            return 0
            ;;
    esac
}

_start_docker_container_if_not_running() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    case $run_in_container in
        "true" | 1)
            set +e
            _check_docker_running
            ret=$?
            set -e
            echo $ret
            if [ $ret = 0 ]; then
                echo "Container '$container_name' already running."
            else 
                echo "Container '$container_name' not running. Running it!"
                _start_docker_container
            fi
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

_stop_docker_container_if_running() {
    run_in_container=${RUN_IN_CONTAINER}
    container_name=${RUN_IN_CONTAINER_NAME}
    case $run_in_container in
        "true" | 1)
            set +e
            _check_docker_running
            ret=$?
            set -e
            echo $ret
            if [ $ret = 0 ]; then
                echo "Container '$container_name' running. Stopping it"
                _stop_docker_container
            else
                echo "Container '$container_name' already stopped!"
            fi
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}