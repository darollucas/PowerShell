<#
.SYNOPSIS
Rename a domain controller (After Reboot).

.DESCRIPTION
This PowerShell script continues the domain controller rename process after the reboot. It removes the old computer name and enumerates the new computer name. Additionally, it can update DNS records if chosen in the first script.

.NOTES
- Run this script with administrative privileges on the domain controller after the reboot.
- Make sure the first script (RenameDC_BeforeReboot.ps1) has been run and the domain controller has been rebooted before executing this script.

#>

# Function to remove the old computer name and enumerate the new computer name
function Continue-RenameDomainController {
    param (
        [string]$OldDCName,
        [string]$NewDCName,
        [string]$UpdateDNS,
        [string]$Enumerate,
        [string]$Domain,
        [string]$IP
    )

    Write-Host "Removing the old computer name and enumerating the new computer name..."
    netdom computername $NewDCName /remove:$OldDCName
    if ($Enumerate -eq "Y" -or $Enumerate -eq "y") {
        netdom computername $NewDCName /enumerate
    }

    # Update DNS records if chosen
    if ($UpdateDNS -eq "Y" -or $UpdateDNS -eq "y") {
        Write-Host "Updating DNS records..."
        dnscmd $NewDCName /RecordDelete $Domain $OldDCName A
        dnscmd $NewDCName /RecordAdd $Domain $NewDCName A $IP
    }

    Write-Host "Domain controller rename completed."
}

# Prompt user for options to continue the rename process
$UpdateDNS = Read-Host "Do you want to update DNS records? (Y/N)"
$Enumerate = Read-Host "Do you want to enumerate the new computer name? (Y/N)"

# Prompt user for the domain name for the dnscmd command, if updating DNS records
if ($UpdateDNS -eq "Y" -or $UpdateDNS -eq "y") {
    $Domain = Read-Host "Enter the domain name for the dnscmd command (e.g., example.com):"
    $IP = Read-Host "Enter the IP address associated with the new domain controller name (e.g., 192.168.1.10):"
}

# Call the function to continue the domain controller rename process
Continue-RenameDomainController -OldDCName $OldDCName -NewDCName $NewDCName -UpdateDNS $UpdateDNS -Enumerate $Enumerate -Domain $Domain -IP $IP