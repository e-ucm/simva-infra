#!/bin/bash
set -euo pipefail

# --- Auto-detect VM name from Vagrantfile ---
echo "🔍 Detecting VM name from Vagrantfile..."
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

# --- SSH CONFIG for VM ---
SSH_CONFIG_PATH="$HOME/.ssh/config"
SSH_DIR="$HOME/.ssh"

# Ensure .ssh folder exists
mkdir -p "$SSH_DIR"

# Get SSH config from Vagrant
echo "📡 Retrieving SSH config from Vagrant..."
if ! vagrant ssh-config --host "$VM_NAME" > /tmp/vagrant_ssh_config 2>/dev/null; then
    echo "❌ Failed to retrieve SSH config from Vagrant."
    exit 1
fi

# Backup existing SSH config if exists
if [[ -f "$SSH_CONFIG_PATH" ]]; then
    cp -f "$SSH_CONFIG_PATH" "$SSH_CONFIG_PATH.bak"
    echo "🗂️  Existing SSH config backed up to $SSH_CONFIG_PATH.bak"
fi

# Remove any existing entry for the same host
if [[ -f "$SSH_CONFIG_PATH" ]]; then
    awk -v host="$VM_NAME" '
    BEGIN {skip=0}
    /^Host[[:space:]]+/ {
        if ($2 == host) {skip=1; next}
        if (skip && /^Host[[:space:]]+/) {skip=0}
    }
    !skip
    ' "$SSH_CONFIG_PATH" > /tmp/ssh_config_cleaned
else
    touch /tmp/ssh_config_cleaned
fi

# Append new Vagrant SSH config
echo "" >> /tmp/ssh_config_cleaned
cat /tmp/vagrant_ssh_config >> /tmp/ssh_config_cleaned

# Overwrite SSH config
mv /tmp/ssh_config_cleaned "$SSH_CONFIG_PATH"
chmod 600 "$SSH_CONFIG_PATH"

echo "✅ Vagrant SSH config added to $SSH_CONFIG_PATH"

# --- Launch VS Code with Remote SSH connection ---
echo "🚀 Opening VS Code Remote SSH for '$VM_NAME'..."
code --file-uri "vscode-remote://ssh-remote+$VM_NAME/home/vagrant/simva-infra/vagrant/simva-infra.code-workspace"

echo "✅ VS Code opened with the correct configuration."
