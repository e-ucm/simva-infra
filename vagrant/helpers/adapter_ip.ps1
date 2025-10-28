# Check if adapter exists
$found = & VBoxManage list hostonlyifs

if (-not $found) {
    Write-Host "Creating $adapter..."
    & VBoxManage hostonlyif create
}

# Extract first Host-Only adapter IP
$ip = (VBoxManage list hostonlyifs |
         Select-String "IPAddress" |
         Select-Object -First 1 |
         ForEach-Object { ($_ -replace ".*IPAddress:\s*", "") })

# Export to environment variable for Vagrant
[System.Environment]::SetEnvironmentVariable("VBOX_HOSTONLY_IP", $ip, "Process")

Set-Content ".\hostonly_ip.txt" $ip

$newIp = ($ip -replace "\.1$", ".2")

Write-Host "Updated IP: $newIp"

# Save to file (for logging or debugging)
Set-Content -Path "external_ip.txt" -Value $newIp

Write-Host "Detected Host-Only IP: $ip"

Set-Content -Path "os.txt" -Value "WINDOWS"