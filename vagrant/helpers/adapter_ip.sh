#!/usr/bin/env bash

simvaenvFile="../docker-stacks/etc/simva.d/simva-env.sh"

# Check if any host-only adapter exists
found=$(VBoxManage list hostonlyifs)

if [[ -z "$found" ]]; then
    echo "Creating host-only adapter..."
    VBoxManage hostonlyif create
fi

# Extract first Host-Only adapter IP
ip=$(VBoxManage list hostonlyifs | grep "IPAddress" | head -n1 | awk '{print $2}')

# Create new IP by replacing last octet from .1 → .10
newIp="${ip%.*}.10"

# Export environment variables for this process
export VBOX_HOSTONLY_IP="$ip"
export VBOX_HOSTOS_NAME="LINUX"   # Change "LINUX" if on macOS or Windows Subsystem
export VBOX_EXTERNAL_IP="$newIp"

echo "Updated IP: $newIp"
echo "Detected Host-Only IP: $ip"

# Update simva-env.sh
if [[ -f "$simvaenvFile" ]]; then
    sed -i.bak "s|^export SIMVA_HOST_EXTERNAL_IP=\".*\"|export SIMVA_HOST_EXTERNAL_IP=\"$newIp\"|" "$simvaenvFile"
fi

# Save to files for logging/debugging
echo "$ip" > hostonly_ip.txt
echo "$newIp" > external_ip.txt
echo "LINUX" > os.txt   # Change as needed
