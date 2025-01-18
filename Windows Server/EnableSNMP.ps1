<#
.SYNOPSIS
This script enables the SNMP Service on a Windows Server and configures it with basic settings.

.DESCRIPTION
The script installs and configures the SNMP Service on a Windows Server. It allows the user to specify the SNMP community strings and authorized managers (IP addresses or hostnames). The script is compatible with Windows Server 2016, 2019, 2022, and 2025.

.NOTES
Script Name: Enable-SNMP.ps1
Created By: Your Name
Version: 1.1

.EXAMPLE
PS> .\Enable-SNMP.ps1
# Run the script and follow the prompts to enable and configure the SNMP Service.

.EXAMPLE
PS> .\Enable-SNMP.ps1 -CommunityStrings "public,private" -AuthorizedManagers "192.168.1.1,192.168.1.2"
# Run the script with predefined community strings and authorized managers.

.EXAMPLE
PS> .\Enable-SNMP.ps1 -Verbose
# Run the script with verbose output to see detailed progress.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string[]]$CommunityStrings = @("public"),

    [Parameter(Mandatory = $false)]
    [string[]]$AuthorizedManagers = @("127.0.0.1")
)

# Function to display a header message
function Show-Header {
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host " SNMP Service Configuration Script" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "This script will enable and configure the SNMP Service on this server."
    Write-Host "Compatible with Windows Server 2016, 2019, 2022, and 2025."
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
}

# Function to install the SNMP Service
function Install-SNMP {
    Write-Verbose "Checking if SNMP Service is installed..."
    $snmpInstalled = Get-WindowsFeature -Name SNMP-Service | Where-Object { $_.Installed -eq $true }

    if (-not $snmpInstalled) {
        Write-Verbose "SNMP Service is not installed. Installing now..."
        try {
            Install-WindowsFeature -Name SNMP-Service -IncludeManagementTools -ErrorAction Stop
            Write-Verbose "SNMP Service installed successfully."
        } catch {
            Write-Verbose "Failed to install SNMP Service: $_"
            Write-Host "Failed to install SNMP Service: $_" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Verbose "SNMP Service is already installed."
    }
}

# Function to configure SNMP community strings and authorized managers
function Configure-SNMP {
    Write-Verbose "Configuring SNMP Service..."

    # Set SNMP community strings
    foreach ($community in $CommunityStrings) {
        Write-Verbose "Adding SNMP community: $community"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" /v $community /t REG_DWORD /d 4 /f | Out-Null
    }

    # Set authorized managers
    foreach ($manager in $AuthorizedManagers) {
        Write-Verbose "Adding authorized manager: $manager"
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" /v $manager /t REG_SZ /d $manager /f | Out-Null
    }

    Write-Verbose "SNMP Service configured successfully."
}

# Function to restart the SNMP Service
function Restart-SNMPService {
    Write-Verbose "Restarting SNMP Service..."
    try {
        Restart-Service -Name SNMP -Force -ErrorAction Stop
        Write-Verbose "SNMP Service restarted successfully."
    } catch {
        Write-Verbose "Failed to restart SNMP Service: $_"
        Write-Host "Failed to restart SNMP Service: $_" -ForegroundColor Red
        exit 1
    }
}

# Main script execution
Show-Header
Install-SNMP
Configure-SNMP
Restart-SNMPService

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " SNMP Service setup completed successfully!" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan