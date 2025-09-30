param(
    [switch]$Stop,
    [switch]$Reload,
    [switch]$Provision
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

# Start VM
$status = vagrant status --machine-readable | ForEach-Object {
    ($_ -split ",")[3]
}
Write-Host $status;
if($Stop) {
    if($status -eq "running") {
        Write-Host "Stopping VM '$VmName'..."
        vagrant halt
        ./helpers/install-rootCA-machine.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem" -Remove
        ./helpers/install-rootCA-user.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem" -Remove
        Write-Host "VM stopped."
    } else {
        Write-Host "Already stopped VM '$VmName'"
    }
    exit 0
} else {
    bash ./helpers/build_hostname.sh
    ./helpers/adapter_ip.ps1
    if($Reload) {
        Write-Host "Reloading VM '$VmName'..."
        if ($status -eq "running") {
            if($Provision) {
                vagrant reload --provision
            } else {
                vagrant reload
            }
        } else {
            if($Provision) {
                vagrant up --provider virtualbox --provision
            } else {
                vagrant up --provider virtualbox
            }
        }
        Write-Host "VM Reloaded."
    } else {
        if ($status -eq "running") {
            Write-Host "Already started VM '$VmName'."
        } else {
            Write-Host "Starting VM '$VmName'..."
            if($Provision) {
                vagrant up --provider virtualbox --provision
            } else {
                vagrant up --provider virtualbox
            }
            Write-Host "VM started."
        }
    }
}
./helpers/install-rootCA-machine.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
./helpers/install-rootCA-user.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
# SSH into VM
vagrant ssh
exit 0