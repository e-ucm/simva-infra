# Start Powershell as administrator

# Install chocolatey if it isn't installed yet
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n allowGlobalConfirmation

# Install VirtualBox
choco install -y Virtualbox --version=7.2.0
# Install Vagrant
choco install -y vagrant --version=2.4.9

# Reboot Windows
