# Windows host-only adapter name
$adapter="VirtualBox Host-Only Ethernet Adapter"

# Check if adapter exists
$found = & VBoxManage list hostonlyifs | Select-String $adapter

if (-not $found) {
    Write-Host "Creating $adapter..."
    & VBoxManage hostonlyif create
}

# Configure IP
& VBoxManage hostonlyif ipconfig $adapter --ip 192.168.56.1 --netmask 255.255.255.0

Write-Host "$adapter ready on 192.168.56.1"

Set-Content -Path "os.txt" -Value "WINDOWS"