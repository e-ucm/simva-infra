#!/usr/bin/env bash
set -e

# Detect OS
OS="$(uname -s)"

if [[ "$OS" == "Linux" || "$OS" == "Darwin" ]]; then
    ADAPTER="vboxnet0"
else
    echo "This script is for Linux/macOS only. Use the PowerShell version on Windows."
    exit 1
fi

# Check if adapter exists
if ! VBoxManage list hostonlyifs | grep -q "$ADAPTER"; then
    echo "Creating $ADAPTER..."
    VBoxManage hostonlyif create
fi

# Configure IP
VBoxManage hostonlyif ipconfig "$ADAPTER" --ip 192.168.56.1 --netmask 255.255.255.0

echo "$ADAPTER ready on 192.168.56.1"

# Start VM
vagrant up

# Get VM IP (assuming adapter 2 is private network)
vagrant ssh -c "ip -4 addr show | grep '192.168.56' | awk '{print \$2}'"
$OS > "os.txt"