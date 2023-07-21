<#
.SYNOPSIS
Reset the secure channel for a domain controller.

.DESCRIPTION
This PowerShell script resets the secure channel for a domain controller. It can be used when you encounter symptoms like access denied errors when accessing the DNS management console or when running nltest commands.

.NOTES
- Run this script with administrative privileges.

#>

# Prompt the user for required information
$DCName = Read-Host "Enter the name of the domain controller (e.g., DC01):"
$DomainUsername = Read-Host "Enter the domain username (e.g., domain\admin):"
$DomainPassword = Read-Host -AsSecureString "Enter the domain password:"

# Convert secure string to plain text
$DomainPasswordPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($DomainPassword))

# Function to reset the secure channel for a domain controller
function Reset-SecureChannel {
    param (
        [Parameter(Mandatory=$true)]
        [string]$DCName,
        [Parameter(Mandatory=$true)]
        [string]$DomainUsername,
        [Parameter(Mandatory=$true)]
        [PSCredential]$DomainPassword
    )

    try {
        net stop kdc
        klist purge
        netdom resetpwd /server:$DCName /userD:$DomainUsername /passwordD:$DomainPassword
        net start kdc

        Write-Host "Secure channel reset completed successfully."
    } catch {
        Write-Warning "Failed to reset secure channel. Error: $_"
    }
}

# Execute the secure channel reset
Reset-SecureChannel -DCName $DCName -DomainUsername $DomainUsername -DomainPassword $DomainPasswordPlainText