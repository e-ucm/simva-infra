param(
    [switch]$Stop,
    [switch]$Reload,
    [int]$Memory,
    [int]$CPU
)

# Check the OS
Write-Host "Checking OS..."

if ($IsWindows) {
    Write-Host "OS : Windows"
    Write-Host "Windows detected."
}
elseif ($IsLinux) {
    Write-Host "OS : Linux"
    Write-Host "Linux detected. Use Bash script (2-run-vagrant-image.sh)."
    exit 1
}
elseif ($IsMacOS) {
    Write-Host "OS : MacOS"
    Write-Host "MacOS detected."
    Write-Host "Linux detected. Use Bash script (2-run-vagrant-image.sh)."
    exit 1
} else {
    Write-Host "OS : Unknown"
    Write-Host "Unknown OS detected. Use Bash script (2-run-vagrant-image.sh)."
    exit 1
}

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
    Write-Host "❌ VBoxManage not found. InstalL it before!"
    return
}

if ($VagrantVersion) {
    Write-Host "✅ Vagrant installed — Version: $VagrantVersion"
} else {
    Write-Host "❌ Vagrant not found. Install it before!"
    return
}

# Start Powershell as administrator
$requiredPlugins = @(
    @{ Name = "vagrant-vbguest"; Version = "0.32.0" },    # VB Guest Additions
    @{ Name = "vagrant-disksize"; Version = "0.1.3" }         # Disk size
    @{ Name = "vagrant-hostmanager"; Version = "1.8.10" }     # hosts file management
)

# Function to check if a plugin exists
function Test-VagrantPluginInstalled($pluginName, $pluginVersion) {
    $pluginList = $(vagrant plugin list);

    foreach ($line in $pluginList) {
        if ($line -match "^\s*$pluginName\s*\(([^,]+)") {
            Write-Output "Installed plugin: $pluginName"
            $installedVersion = $matches[1].Trim()
            Write-Output "Installed version: $installedVersion"
            if (-not $pluginVersion -or $installedVersion -eq $pluginVersion) {
                return $true
            }
        }
    }
    return $false
}

foreach ($plugin in $requiredPlugins) {
    if (-not (Test-VagrantPluginInstalled $plugin.Name $plugin.Version)) {
        if ($plugin.Version) {
            Write-Output "Installing $($plugin.Name) ($($plugin.Version))..."
            vagrant plugin install --plugin-source https://rubygems.org $($plugin.Name) --plugin-version $($plugin.Version)
        } else {
            Write-Output "Installing latest $($plugin.Name)..."
            vagrant plugin install --plugin-source https://rubygems.org $($plugin.Name)
        }
    } else {
        if ($plugin.Version) {
            Write-Output "$($plugin.Name) ($($plugin.Version)) already installed."
        } else {
            Write-Output "$($plugin.Name) already installed."
        }
    }
}

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

# Start VM
$status = vagrant status --machine-readable | ForEach-Object {
    ($_ -split ",")[3]
}
Write-Host $status;
if($Stop) {
    if($status -eq "running") {
        Write-Host "Stopping VM '$VmName'..."
        vagrant halt
        ./helpers/install-rootCA.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem" -Remove
        Write-Host "VM stopped."
    } else {
        Write-Host "Already stopped VM '$VmName'"
    }
    exit 0
} else {
    if(!$Memory) {
        $Memory=4096
    }
    [System.Environment]::SetEnvironmentVariable("VBOX_MEMORY", $Memory, "Process")
    if(!$CPU) {
        $CPU=8
    }
    [System.Environment]::SetEnvironmentVariable("VBOX_CPU", $CPU, "Process")
    ./helpers/build_hostname.ps1
    ./helpers/adapter_ip.ps1
    ./helpers/set_to_local_dev.ps1
    if($Reload) {
        Write-Host "Reloading VM '$VmName'..."
        if ($status -eq "running") {
            vagrant reload
        } else {
            vagrant up --provider virtualbox
        }
        Write-Host "VM Reloaded."
    } else {
        if ($status -eq "running") {
            Write-Host "Already started VM '$VmName'."
            vagrant provision
            Write-Host "VM provisioned."
        } else {
            Write-Host "Starting VM '$VmName'..."
            vagrant up --provider virtualbox
            Write-Host "VM started."
        }
    }
}
./helpers/install-rootCA.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
# SSH into VM
vagrant ssh
exit 0