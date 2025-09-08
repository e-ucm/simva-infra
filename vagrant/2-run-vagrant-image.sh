#!/usr/bin/env bash

# Usage: ./2-run-vagrant-image.sh [--stop]

STOP=false
RELOAD=false
for arg in "$@"; do
    case $arg in
        --stop)
        STOP=true
        shift
        ;;
        --reload)
        RELOAD=true
        shift
        ;;
    esac
done

# --- Auto-detect VM name from Vagrantfile ---
VM_NAME="default"
if [[ -f "./Vagrantfile" ]]; then
    # Look for vb.name = "something"
    if VM_LINE=$(grep -E 'vb\.name\s*=\s*["'\''](.+)["'\'']' Vagrantfile); then
        if [[ $VM_LINE =~ ['"](.+)['"] ]]; then
            VM_NAME="${BASH_REMATCH[1]}"
            echo "Detected VM name: $VM_NAME"
        fi
    else
        echo "No VM name defined in Vagrantfile. Using default: $VM_NAME"
    fi
else
    echo "Vagrantfile not found. Using default VM name: $VM_NAME"
fi

# Host folder (parent of current directory)
HOST_FOLDER=$(realpath ..)

# Function to monitor VM and stop it
monitor_vm() {
    local vm_name=$1
    while true; do
        sleep 5
        STATUS=$(vagrant status "$vm_name" --machine-readable | awk -F, '$4=="running"{print $4}')
        if [[ -n $STATUS ]]; then
            echo "Stopping VM '$vm_name'..."
            vagrant halt "$vm_name"
            echo "VM stopped."
        fi
    done
}

# Check VM status
STATUS=$(vagrant status "$VM_NAME" --machine-readable | awk -F, '{print $4}')
echo $status

if $STOP; then
    if [[ $STATUS == "running" ]]; then
        echo "Stopping VM '$VM_NAME'..."
        vagrant halt "$VM_NAME"
        # Call the root CA removal script
        ./helpers/install-rootCA.sh --certPath "../docker-stacks/config/tls/ca/rootCA.pem" --remove
        echo "VM stopped."
    else
        echo "VM '$VM_NAME' is already stopped."
    fi
elif $RELOAD; then
    echo "Reloading VM '$VM_NAME'..."
    vagrant reload "$VM_NAME"
    # Call the root CA removal script
    ./helpers/install-rootCA.sh --certPath "../docker-stacks/config/tls/ca/rootCA.pem"
    echo "VM reloaded."
    # SSH into VM
    vagrant ssh "$VM_NAME"
else
    if [[ $STATUS  == "running" ]]; then
        echo "VM '$VM_NAME' is already running."
    else
        echo "Starting VM '$VM_NAME'..."
        ./build_hostname.sh
        monitor_vm "$VM_NAME" &  # Start monitoring in background
        vagrant up --provider virtualbox --provision
        ./helpers/install-rootCA.sh --certPath "../docker-stacks/config/tls/ca/rootCA.pem"
        echo "VM started."
    fi
    # SSH into VM
    vagrant ssh "$VM_NAME"
fi