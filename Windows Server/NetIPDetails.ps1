<#
.SYNOPSIS
This script retrieves network configuration details including IP address, subnet mask, default gateway, DHCP status, DNS servers, MAC address, and domain for a given server.

.DESCRIPTION
The script prompts the user for a server name and then gathers various network configuration details for that server. It displays the information on the console. This script is compatible with PowerShell versions 5.1, 6, 7, and 8 and has been tested on Windows Server versions from 2012 R2 to 2022.

.NOTES
Script Name: NetIPdetails.ps1
Created By: TechBaes IT
Version: 1.0

.EXAMPLE
PS> .\NetIPdetails.ps1
# Run the script and enter the server name when prompted to retrieve and display its network configuration details.

#>

function NetIPdetails {
    # Prompt the user for the server name
    $computerName = Read-Host "Enter the server name"

    # Check if the computer name is entered or not
    if (-not $computerName) {
        Write-Error "No server name entered. Exiting function."
        return
    }

    # Test the connection to the server
    if (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
        try {
            # Using Get-CimInstance for better compatibility across PowerShell versions
            $Networks = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -ComputerName $computerName | Where-Object { $_.IPEnabled }
        } catch {
            Write-Warning "Error occurred while querying $computerName."
            return
        }

        foreach ($Network in $Networks) {
            $IPAddress = $Network.IpAddress[0]
            $SubnetMask = $Network.IPSubnet[0]
            $DefaultGateway = $Network.DefaultIPGateway[0]
            $DNSServers = ($Network.DNSServerSearchOrder -join ", ")
            $Description = $Network.Description
            $DHCPEnabled = if ($Network.DHCPEnabled) { "Yes" } else { "No" }
            $MACAddress = $Network.MACAddress
            $Domain = $Network.DNSDomain

            # Output to console
            Write-Output "Server: $computerName"
            Write-Output "Description: $Description"
            Write-Output "IP Address: $IPAddress"
            Write-Output "Subnet Mask: $SubnetMask"
            Write-Output "Default Gateway: $DefaultGateway"
            Write-Output "DHCP Enabled: $DHCPEnabled"
            Write-Output "DNS Servers: $DNSServers"
            Write-Output "MAC Address: $MACAddress"
            Write-Output "Domain: $Domain"
        }
    } else {
        Write-Error "Cannot reach server: $computerName"
    }
}

# Call the function to get IP details
NetIPdetails