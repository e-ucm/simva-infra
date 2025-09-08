#!/bin/bash
HOSTONLY_IP="192.168.253.1"      # Host-side IP of host-only adapter
NETMASK="255.255.255.0"
HOST_IF="vboxnet0"               # VirtualBox host-only adapter name

# --- 1. Create host-only adapter if missing ---
EXISTS=$(VBoxManage.exe list hostonlyifs | grep -c "$HOST_IF")
if [ "$EXISTS" -eq 0 ]; then
  echo "Creating host-only adapter $HOST_IF..."
  VBoxManage.exe hostonlyif create
  VBoxManage.exe hostonlyif ipconfig "$HOST_IF" --ip "$HOSTONLY_IP" --netmask "$NETMASK"
else
  echo "Host-only adapter $HOST_IF exists, configuring IP..."
  VBoxManage.exe hostonlyif ipconfig "$HOST_IF" --ip "$HOSTONLY_IP" --netmask "$NETMASK"
fi