# Start Powershell as administrator
$requiredPlugins = @(
    @{ Name = "vagrant-vbguest"; Version = "0.32.0" },        # VB Guest Additions
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
            vagrant plugin install $($plugin.Name) --plugin-version $($plugin.Version)
        } else {
            Write-Output "Installing latest $($plugin.Name)..."
            vagrant plugin install $($plugin.Name)
        }
    } else {
        if ($plugin.Version) {
            Write-Output "$($plugin.Name) ($($plugin.Version)) already installed."
        } else {
            Write-Output "$($plugin.Name) already installed."
        }
    }
}


# Reboot Windows