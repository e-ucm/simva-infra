# Start Powershell as administrator
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 

choco feature enable -n allowGlobalConfirmation

winget install --id Microsoft.PowerShell --source winget

function Get-CommandVersion($cmd) {
    $result = & $cmd --version 2>$null
    if ($LASTEXITCODE -eq 0) { return $result.Trim() }
    return $null
}

$VBoxVersion = Get-CommandVersion "VBoxManage"
$VagrantVersion = Get-CommandVersion "vagrant"

if ($VBoxVersion) {
    Write-Host "✅ VBoxManage installed — Version: $VBoxVersion"
} else {
    Write-Host "❌ VBoxManage not found. Installing..."
    # Install VirtualBox
    choco install -y Virtualbox --version=7.2.0 
}

if ($VagrantVersion) {
    Write-Host "✅ Vagrant installed — Version: $VagrantVersion"
} else {
    Write-Host "❌ Vagrant not found. Installing..."
    # Install Vagrant
    choco install -y vagrant --version=2.4.9
}

# Reboot Windows