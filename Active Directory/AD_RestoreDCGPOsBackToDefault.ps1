<#
.SYNOPSIS
This script restores the Default Domain Policy and Default Domain Controller Policy settings to their default configurations.

.DESCRIPTION
This script uses the dcgpofix tool to restore the Default Domain Policy and Default Domain Controller Policy settings to their default configurations. It prompts the user for the domain name and provides options to link the restored GPOs to their respective targets and run gpupdate.

.NOTES
Author: TechBase IT
Date: 08/16/2023

#>

# Prompt for the domain name
$domainName = Read-Host "Enter the domain name (e.g., yourdomain.com):"

# Backup current GPOs before making changes
$backupPath = "C:\GPO_Backup"
New-Item -ItemType Directory -Path $backupPath -Force

# Backup Default Domain Policy and Default Domain Controller Policy
Backup-GPO -Name "Default Domain Policy" -Path "$backupPath\DomainPolicyBackup" -Comment "Backup of Default Domain Policy"
Backup-GPO -Name "Default Domain Controller Policy" -Path "$backupPath\DCPolicyBackup" -Comment "Backup of Default Domain Controller Policy"

# Restore Default Domain Policy and Default Domain Controller Policy to default settings
dcgpofix /ignoreschema /target:Domain
dcgpofix /ignoreschema /target:DC

# Link Default Domain Policy
$domainPolicyGUID = "31B2F340-016D-11D2-945F-00C04FB984F9"
New-GPLink -Name "Default Domain Policy" -Target "DC=$domainName" -LinkEnabled Yes -GUID $domainPolicyGUID

# Link Default Domain Controller Policy
$dcPolicyGUID = "6AC1786C-016F-11D2-945F-00C04FB984F9"
New-GPLink -Name "Default Domain Controller Policy" -Target "OU=Domain Controllers,DC=$domainName" -LinkEnabled Yes -GUID $dcPolicyGUID

# Prompt the user if they want to run gpupdate
$runGpupdate = Read-Host "Do you want to run gpupdate to apply the changes immediately? (Y/N)"
if ($runGpupdate -eq "Y" -or $runGpupdate -eq "y") {
    gpupdate /force
}

Write-Host "Restoration and configuration complete."