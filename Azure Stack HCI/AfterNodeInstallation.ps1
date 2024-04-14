<#
.SYNOPSIS
Configures an Azure Stack HCI node by setting a complex Administrator password, configuring a time server, installing Hyper-V, and renaming the host.

.DESCRIPTION
This PowerShell script provides an interactive way to configure essential settings on an Azure Stack HCI node. It changes the Administrator password to meet Azure's complexity requirements, sets a valid NTP time server, installs the Hyper-V role, and allows for renaming the host.

.EXAMPLE
PS> .\ConfigureAzureStackHCINode.ps1

This example starts the interactive script, guiding the user through each configuration step.

.NOTES
Author: TechBase IT
Requires Administrator privileges. Ensure you have the necessary permissions before executing.
#>

# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit
}

# Configure NTP time server
Write-Host "Configuring NTP time server..."
w32tm /config /manualpeerlist:"0.at.pool.ntp.org 1.at.pool.ntp.org 2.at.pool.ntp.org 3.at.pool.ntp.org" /syncfromflags:manual /update
w32tm /query /status
Write-Host "NTP time server configuration completed."

# Change Administrator password
$Password = Read-Host "Enter the new password for the Administrator account" -AsSecureString
$UserAccount = Get-LocalUser -Name "Administrator"
$UserAccount | Set-LocalUser -Password $Password
Write-Host "Administrator password has been updated."

# Install Hyper-V role
Write-Host "Installing Hyper-V role..."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
Write-Host "Hyper-V role installation completed."

# Rename the host
$NewHostName = Read-Host "Enter the new host name"
Rename-Computer -NewName $NewHostName -Restart
Write-Host "Host will be renamed to $NewHostName and restarted."