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
$existing = Get-ChildItem -Path Cert:\CurrentUser\Root | Where-Object { $_.Thumbprint -eq $fingerprint }

if ($Remove) {
    if ($existing) {
        Write-Output "🗑 Removing RootCA from Windows Root store..."
        Start-Process -FilePath "certutil.exe" `
            -ArgumentList @("-user","-delstore", "Root", "`"$fingerprint`"") `
            -Verb RunAs -Wait
        Write-Output "✅ RootCA removed from Windows Root store."
    } else {
        Write-Output "⚠️ RootCA not found in Windows Root store, nothing to remove."
    }
}
else {
    if ($existing) {
        Write-Output "✅ RootCA already installed in Windows Root store."
    } else {
        Write-Output "📥 Installing RootCA into Windows Root store..."
        Start-Process -FilePath "certutil.exe" `
            -ArgumentList @("-user", "-addstore", "Root", "`"$certPath`"") `
            -Verb RunAs -Wait
        Write-Output "✅ Installed in Windows Root store."
    }
}