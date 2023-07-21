<#
.SYNOPSIS
Rename a domain controller (Before Reboot).

.DESCRIPTION
This interactive PowerShell script renames a domain controller and provides options to update DNS records and enumerate. After the reboot, run the second script (RenameDC_AfterReboot.ps1) to continue the script execution.

.NOTES
- Run this script with administrative privileges on the domain controller to be renamed.
- Make sure you have a backup and recovery plan in place before performing the rename operation.

#>

# Function to rename the domain controller and make it the primary computer name
function Rename-DomainController {
    param (
        [string]$OldDCName,
        [string]$NewDCName
    )

    Write-Host "Renaming domain controller..."
    netdom computername $OldDCName /add:$NewDCName
    netdom computername $OldDCName /makeprimary:$NewDCName
}

# Prompt user for the old and new domain controller names
$OldDCName = Read-Host "Enter the current domain controller name (e.g., OldDC01.example.com):"
$NewDCName = Read-Host "Enter the new domain controller name (e.g., NewDC01.example.com):"

# Prompt user for options to update DNS and enumerate
$UpdateDNS = Read-Host "Do you want to update DNS records? (Y/N)"
$Enumerate = Read-Host "Do you want to enumerate the new computer name? (Y/N)"

# Call the function to rename the domain controller
Rename-DomainController -OldDCName $OldDCName -NewDCName $NewDCName

# Restart the domain controller and inform the user to run the second script after the reboot
Write-Host "Restarting domain controller..."
Write-Host "After the reboot, run the second script (RenameDC_AfterReboot.ps1) to continue the domain controller rename process."
shutdown /r /t 0