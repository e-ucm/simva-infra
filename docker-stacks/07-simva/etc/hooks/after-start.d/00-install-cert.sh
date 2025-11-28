#!/usr/bin/env bash
set -euo pipefail
[[ "${DEBUG:-false}" == "true" ]] && set -x

export RUN_IN_CONTAINER=true
export RUN_IN_AS_SPECIFIC_USER="root"

container_list=("simva-api" "simva-front" "simva-trace-allocator");
for container_name in "${container_list[@]}"; do
    export RUN_IN_CONTAINER_NAME="$container_name"
    # Get the internal CA certificate content from inside the container
    internal_ca=$("${SIMVA_BIN_HOME}/run-command.sh" /bin/bash -c "cat \"/usr/local/share/ca-certificates/internal-CA.crt\" 2>/dev/null")
    if [[ -z "$internal_ca" ]]; then
        echo "No internal CA certificate found inside container '$container_name'."
        install=true
    else 
        # Compute sha256 of internal CA content
        internal_ca_cert_sha256sum=$(printf "%s" "$internal_ca" | sha256sum | awk '{print $1}')
        # Compute sha256 of the fullchain certificate file on host
        ca_cert_sha256sum=$(sha256sum "${SIMVA_ROOT_CA_FILE}" | awk '{print $1}')
        echo "Internal CA cert sha256sum: $internal_ca_cert_sha256sum"
        echo "CA cert sha256sum: $ca_cert_sha256sum"
        if [[ $internal_ca_cert_sha256sum == $ca_cert_sha256sum ]]; then
            install=false
        else
            install=true
        fi
    fi
    
    # Compare and install if different
    if [[ $install == "true" ]]; then
        echo "Certificates differ — updating CA inside container..."
        "${SIMVA_BIN_HOME}/run-command.sh" /bin/bash -c "cp /var/lib/simva/ca/$SIMVA_ROOT_CA_FILENAME \"/usr/local/share/ca-certificates/internal-CA.crt\";
            update-ca-certificates;
            cat /etc/ca-certificates.conf;
            echo \"Certificate added!\";"
    else
        echo "Certificates match — no update needed."
    fi
done