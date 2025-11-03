param(
    [string]$certPath = $env:ROOTCA_PATH,
    [switch]$Remove
)

if (-not $certPath) {
    Write-Error "❌ No certificate path provided. Pass it as a parameter or set ROOTCA_PATH."
    exit 1
}

if (-not (Test-Path $certPath)) {
    Write-Error "❌ Certificate file not found: $certPath"
    exit 1
}

# Load the certificate
$cert = Get-PfxCertificate -FilePath $certPath
$fingerprint = $cert.Thumbprint.ToUpper()

Write-Output "📌 Fingerprint of provided RootCA: $fingerprint"

# Check if it's already in the Root store
$existing = Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object { $_.Thumbprint -eq $fingerprint }

if ($Remove) {
    if ($existing) {
        # --- Check if already running as Administrator ---
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        Write-Output "🗑 Removing RootCA from Windows Root store..."
        # Remove the certificate from the Trusted Root Certification Authorities store
        if($isAdmin) {
            Remove-Item -Path "Cert:\LocalMachine\Root\$fingerprint" -Force
        } else {
            $cmd="Remove-Item -Path 'Cert:\LocalMachine\Root\$fingerprint' -Force"
            Start-Process powershell.exe -Verb RunAs -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-Command", "$cmd"
            ) -Wait
        }
        Write-Output "✅ RootCA removed from Windows Root store."
    } else {
        Write-Output "⚠️ RootCA not found in Windows Root store, nothing to remove."
    }
}
else {
    if ($existing) {
        Write-Output "✅ RootCA already installed in Windows Root store."
    } else {
        # --- Check if already running as Administrator ---
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        Write-Output "📥 Installing RootCA into Windows Root store..."
        # Import the certificate to the Trusted Root Certification Authorities store
        if($isAdmin) {
            Import-Certificate -FilePath "$certPath" -CertStoreLocation Cert:\LocalMachine\Root
        } else {
            # Convert to absolute path
            $certPath = (Resolve-Path -Path $certPath).Path
            $cmd="Import-Certificate -FilePath `"$certPath`" -CertStoreLocation Cert:\LocalMachine\Root"
            Start-Process powershell.exe -Verb RunAs -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-Command", "$cmd"
            ) -Wait
        }
        Write-Output "✅ Installed in Windows Root store."
    }
}