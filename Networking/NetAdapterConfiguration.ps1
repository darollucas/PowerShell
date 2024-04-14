<#
.SYNOPSIS
Configures network adapters on Windows Server Core, Hyper-V Server Core, and Azure Stack HCI nodes.

.DESCRIPTION
An interactive PowerShell script that lists all network adapters and allows the user to select an adapter by number to configure its IP address, subnet mask, gateway, primary DNS server, secondary DNS server, and VLAN ID. Designed for environments without a GUI.

.EXAMPLE
PS> .\ConfigureNetworkAdapter.ps1

Starts the script, listing all network adapters and guiding the user through configuring a selected adapter.

.NOTES
Author: TechBase IT
Requires Administrator privileges. Ensure you have the necessary permissions before executing.
#>

# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit
}

# List all network adapters and allow the user to pick one
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object Name, InterfaceDescription
if ($adapters.Count -eq 0) {
    Write-Host "No network adapters found."
    exit
}

Write-Host "Available Network Adapters:"
$adapters | ForEach-Object { $index = [Array]::IndexOf($adapters, $_); Write-Host "$index. $($_.Name) - $($_.InterfaceDescription)" }

$selectedAdapterIndex = Read-Host "Enter the number of the adapter you wish to configure"
$selectedAdapter = $adapters[$selectedAdapterIndex]

if ($selectedAdapter -eq $null) {
    Write-Error "Invalid selection."
    exit
}

# Collect network configuration from the user
$ipAddress = Read-Host "Enter IP address for $($selectedAdapter.Name)"
$subnetPrefixLength = Read-Host "Enter Subnet Prefix Length (e.g., 24 for 255.255.255.0)"
$gateway = Read-Host "Enter Default Gateway"
$primaryDns = Read-Host "Enter Primary DNS Server"
$secondaryDns = Read-Host "Enter Secondary DNS Server (Press Enter to skip)"
$vlanId = Read-Host "Enter VLAN ID (Press Enter to skip)"

# Apply network configuration
New-NetIPAddress -InterfaceAlias $selectedAdapter.Name -IPAddress $ipAddress -PrefixLength $subnetPrefixLength -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceAlias $selectedAdapter.Name -ServerAddresses ($primaryDns,$secondaryDns).Where({ $_ -ne '' })

if (![string]::IsNullOrWhiteSpace($vlanId)) {
    Set-NetAdapterVlan -InterfaceAlias $selectedAdapter.Name -VlanId $vlanId
}

Write-Host "Configuration complete for $($selectedAdapter.Name)."
