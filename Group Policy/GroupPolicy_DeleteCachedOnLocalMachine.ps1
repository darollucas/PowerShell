<#
.SYNOPSIS
This script clears cached Group Policy settings and provides an option to run gpupdate afterward.

.DESCRIPTION
This script clears cached Group Policy settings on the local machine and provides an option to run gpupdate to apply new policies.

.NOTES
Author: TechBase IT
Date: 08/16/2023

#>

# Check if the script is running with administrator privileges
$isAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Please run this script with administrator privileges."
    Exit 1
}

# Clear cached Group Policy settings

$registryKeys = @(
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies",
    "HKCU\Software\Microsoft\WindowsSelfHost",
    "HKCU\Software\Policies",
    "HKLM\Software\Microsoft\Policies",
    "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies",
    "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate",
    "HKLM\Software\Microsoft\WindowsSelfHost",
    "HKLM\Software\Policies",
    "HKLM\Software\WOW6432Node\Microsoft\Policies",
    "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies",
    "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate"
)

foreach ($key in $registryKeys) {
    Write-Host "Attempting to delete registry key: $key"
    $output = reg delete $key /f 2>&1
    Write-Host $output
}

# Prompt user to run gpupdate

$runGpupdate = Read-Host "Cached Group Policy settings cleared. Do you want to run gpupdate now? (Y/N)"

if ($runGpupdate -eq "Y" -or $runGpupdate -eq "y") {
    gpupdate /force
}