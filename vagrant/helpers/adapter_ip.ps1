$OUTPUT_EXTERNAL_IP_FILE="external_ip.txt"
$OUTPUT_FILE="adapter_name.txt"

# === CONFIGURATION ===
$vmIP = Get-Content $OUTPUT_EXTERNAL_IP_FILE
$netmask = "255.255.255.0"

# Extract network base from IP (e.g., 192.168.56.1)
$octets = $vmIP.Split('.')
$networkBase = "$($octets[0]).$($octets[1]).$($octets[2]).1"

# Check existing host-only adapters
$adapters = VBoxManage list hostonlyifs | Select-String "Name|IPAddress"

$foundAdapter = $null
for ($i = 0; $i -lt $adapters.Count; $i += 2) {
    $name = $adapters[$i].ToString().Split(":")[1].Trim()
    $ip   = $adapters[$i+1].ToString().Split(":")[1].Trim()
    if ($ip -eq $networkBase) {
        $foundAdapter = $name
        break
    }
}

# Create host-only adapter if missing
if (-not $foundAdapter) {
    Write-Output "No host-only adapter found for network $networkBase. Creating one..."
    $adapterName = VBoxManage hostonlyif create | ForEach-Object { ($_ -split '"')[1] } 
    if(-not $adapterName) {
        $adapterName = "VirtualBox Host-Only Ethernet Adapter"
    }
    VBoxManage hostonlyif ipconfig $adapterName --ip $networkBase --netmask $netmask
    $foundAdapter = $adapterName
} else {
    Write-Output "Found existing host-only adapter: $foundAdapter"
}

Write-Output "Adapter ready: $foundAdapter. You can now use this adapter in your Vagrantfile."

# Write the adapter name to the file
$foundAdapter | Out-File -FilePath $OUTPUT_FILE -Encoding UTF8