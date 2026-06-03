param(
    [switch]$Stop,
    [switch]$Reload,
    [int]$Memory,
    [int]$CPU,
    [switch]$fixNetwork=$false
)

# Check the OS
Write-Host "Checking OS..."

# Improved OS detection for PowerShell Core and Windows PowerShell
if ($PSVersionTable.PSEdition -eq 'Desktop' -or $env:OS -eq 'Windows_NT') {
    Write-Host "OS : Windows"
    Write-Host "Windows detected."

    # --- Ensure VBoxManage and Vagrant are in PATH ---
    function Add-ToPathIfExists($dir) {
        if (Test-Path $dir) {
            if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $dir })) {
                $env:PATH = "$dir;" + $env:PATH
                Write-Host "Added to PATH: $dir"
            }
        }
    }

    # Common install locations
    $vboxDirs = @(
        "$env:ProgramFiles\Oracle\VirtualBox",
        "$env:ProgramFiles(x86)\Oracle\VirtualBox"
    )
    $vagrantDirs = @(
        "$env:ProgramFiles\Vagrant\bin",
        "$env:ProgramFiles(x86)\Vagrant\bin"
    )

    $foundVBox = $false
    foreach ($dir in $vboxDirs) {
        if (Test-Path (Join-Path $dir 'VBoxManage.exe')) {
            Add-ToPathIfExists $dir
            $foundVBox = $true
            break
        }
    }

    $foundVagrant = $false
    foreach ($dir in $vagrantDirs) {
        if (Test-Path (Join-Path $dir 'vagrant.exe')) {
            Add-ToPathIfExists $dir
            $foundVagrant = $true
            break
        }
    }
} elseif ($PSVersionTable.Platform -eq 'Unix' -and $env:OSTYPE -like '*linux*') {
    Write-Host "OS : Linux"
    Write-Host "Linux detected. Use Bash script (2-run-vagrant-image.sh)."
    exit 1
} elseif ($PSVersionTable.Platform -eq 'Unix' -and $env:OSTYPE -like '*darwin*') {
    Write-Host "OS : MacOS"
    Write-Host "MacOS detected. Use Bash script (2-run-vagrant-image.sh)."
    exit 1
} else {
    Write-Host "OS : Unknown"
    Write-Host "Unknown OS detected. Use Bash script (2-run-vagrant-image.sh)."
    exit 1
}

if($fixNetwork) {
    Write-Host "fix network : ON"
    [System.Environment]::SetEnvironmentVariable("FIX_NETWORK_ERROR", "True", "Process")
} else {
    Write-Host "fix network : OFF"
}

function Get-CommandVersion($cmd) {
    $result = & $cmd --version 2>$null
    if ($LASTEXITCODE -eq 0) { return $result.Trim() }
    return $null
}

function Get-FreePhysicalRamGb {
    try {
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $freeBytes = [double]$osInfo.FreePhysicalMemory * 1KB
        return [math]::Round($freeBytes / 1GB, 2)
    } catch {
        return $null
    }
}

function Get-LogicalCpuCount {
    try {
        $cpuInfo = Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop
        return ($cpuInfo | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
    } catch {
        return $null
    }
}

if ($foundVBox) {
    $VBoxVersion = Get-CommandVersion "VBoxManage"
    Write-Host "✅ VBoxManage installed — Version: $VBoxVersion"
} else {
    Write-Host "❌ VBoxManage not found. InstalL it before!"
    return
}

if ($foundVagrant) {
    $VagrantVersion = Get-CommandVersion "vagrant"
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

$VmName = "SIMVA-INFRA-VAGRANT"
[System.Environment]::SetEnvironmentVariable("VBOX_NAME", $VmName, "Process")
if(Test-Path -Path "./.vagrant/machines/default" -PathType Container) {
    Copy-Item -Path "./.vagrant/machines/default" -Destination "./.vagrant/machines/default_backup" -Recurse -Force
    Move-Item -Path "./.vagrant/machines/default" -Destination "./.vagrant/machines/$VmName" -Force
    Write-Host "Renamed .vagrant/machines/default to .vagrant/machines/$VmName"
} else {
    Write-Host "No existing .vagrant/default directory found. Skipping rename."
}


# Start VM
$status = vagrant status --machine-readable | ForEach-Object {
    ($_ -split ",")[3]
}
Write-Host $status;
if($Stop) {
    if($status -eq "running") {
        Write-Host "Stopping VM '$VmName'..."
        vagrant halt $VmName
        ./helpers/install-rootCA.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem" -Remove
        Write-Host "VM stopped."
    } else {
        Write-Host "Already stopped VM '$VmName'"
    }
    exit 0
} else {
    if(!$Memory) {
        $Memory=4
    }

    if(!$CPU) {
        $CPU=3
    }

    $reservedRamGb = 2
    $freeRamGb = Get-FreePhysicalRamGb
    $allowedRamGb = if ($null -ne $freeRamGb) { [math]::Max(0, [math]::Floor($freeRamGb - $reservedRamGb)) } else { $null }

    if ($null -eq $freeRamGb) {
        Write-Warning "Could not determine free host RAM. Skipping RAM availability check."
    } elseif ($allowedRamGb -lt 1) {
        Write-Error "Not enough free RAM on host after reserving ${reservedRamGb}GB for the OS. Free RAM: ${freeRamGb}GB."
        exit 1
    } elseif ($Memory -gt $allowedRamGb) {
        Write-Error "Not enough free RAM on host with OS headroom reserved. Requested ${Memory}GB, free ${freeRamGb}GB, allowed ${allowedRamGb}GB after reserving ${reservedRamGb}GB for the OS."
        exit 1
    } else {
        Write-Host "Host RAM check passed: requested ${Memory}GB, free ${freeRamGb}GB, reserving ${reservedRamGb}GB for OS, allowed ${allowedRamGb}GB"
    }

    $logicalCpuCount = Get-LogicalCpuCount
    $reservedCpu = if ($null -ne $logicalCpuCount -and $logicalCpuCount -ge 4) { 2 } else { 1 }
    $allowedCpu = if ($null -ne $logicalCpuCount) { [math]::Max(1, $logicalCpuCount - $reservedCpu) } else { $null }

    if ($null -eq $logicalCpuCount) {
        Write-Warning "Could not determine host logical CPU count. Skipping CPU availability check."
    } elseif ($CPU -gt $allowedCpu) {
        Write-Error "Not enough CPU headroom on host. Requested ${CPU} vCPUs, host has ${logicalCpuCount} logical CPUs, allowed ${allowedCpu} after reserving ${reservedCpu} for the OS."
        exit 1
    } else {
        Write-Host "Host CPU check passed: requested ${CPU} vCPUs, host has ${logicalCpuCount} logical CPUs, reserving ${reservedCpu} for OS, allowed ${allowedCpu}"
    }

    $memoryMb = $Memory * 1024
    [System.Environment]::SetEnvironmentVariable("VBOX_MEMORY", $memoryMb, "Process")
    [System.Environment]::SetEnvironmentVariable("VBOX_CPU", $CPU, "Process")
    Write-Host "Setting VM resources: Memory=${Memory}GB (${memoryMb}MB), CPU=${CPU} cores"
    ./helpers/build_hostname.ps1
    ./helpers/adapter_ip.ps1
    ./helpers/set_to_local_dev.ps1
    if($Reload) {
        Write-Host "Reloading VM '$VmName'..."
        if ($status -eq "running") {
            vagrant reload $VmName
        } else {
            vagrant up $VmName --provider virtualbox
        }
        Write-Host "VM Reloaded."
    } else {
        if ($status -eq "running") {
            Write-Host "Already started VM '$VmName'."
            vagrant provision
            Write-Host "VM provisioned."
        } else {
            Write-Host "Starting VM '$VmName'..."
            vagrant up $VmName --provider virtualbox
            Write-Host "VM started."
        }
    }
}
./helpers/install-rootCA.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
# SSH into VM
vagrant ssh $VmName
exit 0