param(
    [switch]$Stop,
    [switch]$Reload
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
    param($VmName, $ShareName)
    while ($true) {
        Start-Sleep -Seconds 5
        # Check if VM is running
        $status = vagrant status $VmName --machine-readable | ForEach-Object {
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
} elseif($Reload) {
    Write-Host "Reloading VM '$VmName'..."
    bash ./helpers/build_hostname.sh
    ./helpers/adapter_ip.ps1
    Start-Job -ScriptBlock $scriptBlock -ArgumentList $VmName, $ShareName | Out-Null
    if ($status -eq "running") {
        vagrant reload --provision
    } else {
        vagrant up --provider virtualbox --provision
    }
    ./helpers/install-rootCA-machine.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
    ./helpers/install-rootCA-user.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
    Write-Host "VM Reloaded."
    # SSH into VM
    vagrant ssh
} else {
    if ($status -eq "running") {
        Write-Host "Already started VM '$VmName'."
    } else {
        Write-Host "Starting VM '$VmName'..."
        bash ./helpers/build_hostname.sh
        ./helpers/adapter_ip.ps1
        Start-Job -ScriptBlock $scriptBlock -ArgumentList $VmName, $ShareName | Out-Null
        vagrant up --provider virtualbox --provision
        Write-Host "VM started."
    }
    ./helpers/install-rootCA-machine.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
    ./helpers/install-rootCA-user.ps1 -certPath "../docker-stacks/config/tls/ca/rootCA.pem"
    # SSH into VM
    vagrant ssh
}