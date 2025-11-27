$simvaenvFile="..\docker-stacks\etc\simva.d\simva-env.sh"

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

$newIp = ($ip -replace "\.1$", ".10")

# Export to environment variable for Vagrant
[System.Environment]::SetEnvironmentVariable("VBOX_HOSTONLY_IP", $ip, "Process")
[System.Environment]::SetEnvironmentVariable("VBOX_HOSTOS_NAME", "WINDOWS", "Process")
[System.Environment]::SetEnvironmentVariable("VBOX_EXTERNAL_IP", $newIp, "Process")

Write-Host "Updated IP: $newIp"
Write-Host "Detected Host-Only IP: $ip"

$content = (Get-Content $simvaenvFile)
$content -replace '^export SIMVA_HOST_EXTERNAL_IP=".*"', "export SIMVA_HOST_EXTERNAL_IP=`"$newIp`"" | Set-Content $simvaenvFile

# Save to file (for logging or debugging)
Set-Content -Path "hostonly_ip.txt" -Value $ip
Set-Content -Path "external_ip.txt" -Value $newIp