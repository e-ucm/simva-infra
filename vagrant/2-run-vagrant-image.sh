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

# Function to get the version of a command
get_command_version() {
    local cmd=$1
    local result
    if result=$($cmd --version 2>/dev/null); then
        echo "$result" | head -n 1
    else
        echo ""
    fi
}

VBoxVersion=$(get_command_version "VBoxManage")
VagrantVersion=$(get_command_version "vagrant")

# Check VBoxManage
if [[ -n "$VBoxVersion" ]]; then
    echo "✅ VBoxManage installed — Version: $VBoxVersion"
else
    echo "❌ VBoxManage not found. Install it before!"
    exit 1
fi

# Check Vagrant
if [[ -n "$VagrantVersion" ]]; then
    echo "✅ Vagrant installed — Version: $VagrantVersion"
else
    echo "❌ Vagrant not found. Install it before!"
    exit 1
fi

# Required Vagrant plugins
declare -A required_plugins=(
    ["vagrant-vbguest"]="0.32.0"
    ["vagrant-disksize"]="0.1.3"
    ["vagrant-hostmanager"]="1.8.10"
)

# Function to check if a plugin is installed
is_vagrant_plugin_installed() {
    local name=$1
    local version=$2
    local plugin_list
    plugin_list=$(vagrant plugin list)

    while IFS= read -r line; do
        if [[ $line =~ ^$name\ \(([^,]+) ]]; then
            installed_version="${BASH_REMATCH[1]}"
            echo "Installed plugin: $name"
            echo "Installed version: $installed_version"
            if [[ -z $version || $installed_version == "$version" ]]; then
                return 0
            fi
        fi
    done <<< "$plugin_list"

    return 1
}

# Install missing plugins
for plugin in "${!required_plugins[@]}"; do
    version="${required_plugins[$plugin]}"
    if ! is_vagrant_plugin_installed "$plugin" "$version"; then
        if [[ -n "$version" ]]; then
            echo "Installing $plugin ($version)..."
            vagrant plugin install --plugin-source https://rubygems.org "$plugin" --plugin-version "$version"
        else
            echo "Installing latest $plugin..."
            vagrant plugin install --plugin-source https://rubygems.org "$plugin"
        fi
    else
        if [[ -n "$version" ]]; then
            echo "$plugin ($version) already installed."
        else
            echo "$plugin already installed."
        fi
    fi
done

# --- Auto-detect VM name from Vagrantfile ---
VM_NAME="default"
if [[ -f "./Vagrantfile" ]]; then
    # Look for vb.name = "something"
    if VM_LINE=$(grep -E 'vb\.name\s*=\s*["'\''](.+)["'\'']' Vagrantfile); then
        if [[ $VM_LINE =~ ['\"](.+)[\"'] ]]; then
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
        ./helpers/build_hostname.sh
        ./helpers/adapter_ip.sh
        ./helpers/set_to_local_dev.sh
        monitor_vm "$VM_NAME" &  # Start monitoring in background
        vagrant up --provider virtualbox --provision
        ./helpers/install-rootCA.sh --certPath "../docker-stacks/config/tls/ca/rootCA.pem"
        echo "VM started."
    fi
    # SSH into VM
    vagrant ssh "$VM_NAME"
fi
