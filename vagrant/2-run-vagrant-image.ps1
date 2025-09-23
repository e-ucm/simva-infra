param(
    [switch]$Stop,
    [switch]$Reload,
    [switch]$VSCode,
    [switch]$NoProvision
)

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

# Start a background job to monitor the VM and clean up
$scriptBlock = {
    param($VmName)
    while ($true) {
        Start-Sleep -Seconds 5
        # Check if VM is running
        $status = vagrant status --machine-readable | ForEach-Object {
            ($_ -split ",")[3]
        } | Select-String "running"

        if ($status) {
            Write-Host "Stopping VM '$VmName'..."
            vagrant halt
            Write-Host "VM stopped."
        }
    }
}

# Start VM
$status = vagrant status --machine-readable | ForEach-Object {
    ($_ -split ",")[3]
}
Write-Host $status;
if($NoProvision) {
    $provisionText=""
} else {
    $provisionText="--provision"
}
if($Stop) {
    if ($status -eq "running") {
        Write-Host "Stopping VM '$VmName'..."
        vagrant halt
        ./helpers/install-rootCA-machine.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem" -Remove
        ./helpers/install-rootCA-user.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem" -Remove
        Write-Host "VM stopped."
    } else {
        Write-Host "Already stopped VM '$VmName'"
    }
    exit 0
} elseif($Reload) {
    Write-Host "Reloading VM '$VmName'..."
    bash ./helpers/build_hostname.sh
    ./helpers/adapter_ip.ps1
    Start-Job -ScriptBlock $scriptBlock -ArgumentList $VmName | Out-Null
    if ($status -eq "running") {
        vagrant reload $provisionText
    } else {
        vagrant up --provider virtualbox $provisionText
    }
    ./helpers/install-rootCA-machine.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
    ./helpers/install-rootCA-user.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
    Write-Host "VM Reloaded."
} else {
    if ($status -eq "running") {
        Write-Host "Already started VM '$VmName'."
    } else {
        Write-Host "Starting VM '$VmName'..."
        bash ./helpers/build_hostname.sh
        ./helpers/adapter_ip.ps1
        Start-Job -ScriptBlock $scriptBlock -ArgumentList $VmName | Out-Null
        vagrant up --provider virtualbox $provisionText
        Write-Host "VM started."
    }
    ./helpers/install-rootCA-machine.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
    ./helpers/install-rootCA-user.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
}
if($VSCode) {
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
} else {
    # SSH into VM
    vagrant ssh
}
exit 0