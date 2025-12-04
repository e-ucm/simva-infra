# --- Auto-detect VM name from Vagrantfile ---
try {
    $vagrantfile = Get-Content -Path "./Vagrantfile" -Raw
    if ($vagrantfile -match 'vb\.name\s*=\s*["''](.+?)["'']') {
        $VmName = $Matches[1]
        Write-Host "Detected VM name: $VmName"
    } else {
        $VmName = "default"
        Write-Host "No VM name defined in Vagrantfile. Using default: $VmName"
    }
} catch {
    Write-Host "Error reading Vagrantfile. Using default VM name."
    $VmName = "default"
}

# SSH CONFIG for  VM
# Path to your SSH config (for VS Code Remote-SSH)
$sshConfigPath = "$env:USERPROFILE\.ssh\config"
# Ensure .ssh folder exists
if (-not (Test-Path "$env:USERPROFILE\.ssh")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" | Out-Null
}
# Get SSH config from Vagrant
$vagrantConfig = $(vagrant ssh-config --host "$VmName") | Out-String
$vagrantConfig.Trim();

if ([string]::IsNullOrWhiteSpace($vagrantConfig)) {
    Write-Error "Failed to retrieve SSH config from Vagrant."
    exit 1
}
# Backup existing config
if (Test-Path $sshConfigPath) {
    Copy-Item $sshConfigPath "$sshConfigPath.bak" -Force
}
# Remove existing entry for the Vagrant host (if already present)
$lines = Get-Content $sshConfigPath -ErrorAction SilentlyContinue
$cleanedLines = @()
$skip = $false
foreach ($line in $lines) {
    if ($line -match "^Host\s+$VmName") {
        $skip = $true
    }
    elseif ($skip -and $line -match "^\s*Host\s+") {
        $skip = $false
        $cleanedLines += $line
    }
    elseif (-not $skip) {
        $cleanedLines += $line
    }
}
# Add new Vagrant SSH config
$cleanedLines += ""
$cleanedLines += $vagrantConfig.Trim()
Write-Host $cleanedLines 

# Write back to SSH config
$cleanedLines | Set-Content -Path $sshConfigPath -Encoding UTF8
Write-Host "✅ Vagrant SSH config added to $sshConfigPath"
Write-Host "You can now use 'Remote-SSH: Connect to Host' and select '$VmName' in VS Code."
code --file-uri "vscode-remote://ssh-remote+$VmName/home/vagrant/simva-infra/vagrant/simva-infra.code-workspace"
Write-Host "✅ VS Code opened with the correct configuration."