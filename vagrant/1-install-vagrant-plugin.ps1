# Start Powershell as administrator
$requiredPlugins = @(
    @{ Name = "vagrant-vbguest"; Version = "0.32.0" },  # pinned
    @{ Name = "vagrant-disksize"; Version = "0.1.3" }     # latest
    @{ Name = "vagrant-hostmanager"; Version = "1.8.10" }  # latest
)

# Function to check if a plugin exists
function Test-VagrantPluginInstalled($pluginName, $pluginVersion) {
    if ($pluginVersion) {
        $installed = vagrant plugin list | Select-String "^$pluginName\s+\($pluginVersion\)"
    } else {
        $installed = vagrant plugin list | Select-String "^$pluginName\s+\("
    }
    return $null -ne $installed
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