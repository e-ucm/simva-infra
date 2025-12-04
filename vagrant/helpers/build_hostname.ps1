#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Config ---
$ENV_INSTALL_PATH = "../docker-stacks/etc/simva.install.d/simva-env.sh"
$ENV_FOLDER = "../docker-stacks/etc/simva.d"
$ENV_FILE = "simva-env.sh"
$ENV_PATH = Join-Path $ENV_FOLDER $ENV_FILE
$ENV_DEV_FILE = "simva-env.dev.sh"
$ENV_DEV_PATH = Join-Path $ENV_FOLDER $ENV_DEV_FILE
$OUTPUT_FILE = "hostnames.txt"
$OUTPUT_EXTERNAL_IP_FILE = "external_ip.txt"
$SIMVA_PROJECT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$env:SIMVA_PROJECT_DIR = $SIMVA_PROJECT_DIR

# --- Load .env ---
if (!(Test-Path $ENV_INSTALL_PATH)) {
    Write-Error "Error: $ENV_INSTALL_PATH not found!"
    exit 1
}

if (!(Test-Path $ENV_PATH)) {
    Write-Error "Error: $ENV_PATH not found!"
    exit 1
}

function Get-SourceEnvFile($path) {
    Get-Content $path | ForEach-Object {
        $_ = $_.Trim()

        # Skip empty lines or comments
        if ($_ -eq "" -or $_ -match '^\s*#') { return }

        # Match: export KEY=value  OR  KEY=value
        if ($_ -match '^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
            $key = $matches[1]
            $value = $matches[2].Trim('"').Trim("'")

            # ✅ Skip unresolved template values like ${VAR}
            if ($value -match '\$\{[^}]+\}') {
                #Skipping unresolved placeholder variable: $key=$value
                return
            } else {
                # Set as environment variable
                Set-Item -Path "Env:$key" -Value $value
            }
        }
    }
}

Get-SourceEnvFile $ENV_PATH
Get-SourceEnvFile $ENV_INSTALL_PATH

$env:SIMVA_ENVIRONMENT
if ($env:SIMVA_ENVIRONMENT -eq "development") {
    Write-Host "IN DEV"
    if (!(Test-Path $ENV_DEV_PATH)) {
        Write-Error "Error: $ENV_DEV_PATH not found!"
        exit 1
    }
    else {
        Get-SourceEnvFile $ENV_DEV_PATH
    }
}

# --- Check mandatory variable ---
if ([string]::IsNullOrWhiteSpace($env:SIMVA_EXTERNAL_DOMAIN)) {
    Write-Error "Error: SIMVA_EXTERNAL_DOMAIN is not set in $ENV_PATH"
    exit 1
}

# --- Build external ip ---
Set-Content -Path $OUTPUT_EXTERNAL_IP_FILE -Value $env:SIMVA_HOST_EXTERNAL_IP

# --- Build hostnames ---
$hostnames = @()
$hostnames += "$($env:SIMVA_TRAEFIK_HOST_SUBDOMAIN).$($env:SIMVA_EXTERNAL_DOMAIN)"

if ($env:SIMVA_SHLINK_USE_SIMVA_EXTERNAL_DOMAIN -eq "false") {
    $hostnames += $env:SIMVA_SHLINK_EXTERNAL_DOMAIN
}

$hostnames += $env:SIMVA_EXTERNAL_DOMAIN

# Loop through all SIMVA_*_HOST_SUBDOMAIN vars
Get-ChildItem Env: | Where-Object { $_.Name -match '^SIMVA_.*_HOST_SUBDOMAIN$' } | ForEach-Object {
    $subdomain = $_.Value
    if ($subdomain) {
        $hostnames += "$subdomain.$($env:SIMVA_EXTERNAL_DOMAIN)"
    }
}

# Write hostnames
Set-Content -Path $OUTPUT_FILE -Value $hostnames

Write-Host "$OUTPUT_FILE generated:"
Get-Content $OUTPUT_FILE
