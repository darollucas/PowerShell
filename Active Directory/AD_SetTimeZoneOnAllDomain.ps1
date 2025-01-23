<#
.SYNOPSIS
This PowerShell script sets the time zone for all domain-joined machines based on user selection.

.DESCRIPTION
The script prompts the user to select a time zone from standard US options and remotely sets it across all domain-joined machines.
It prompts for domain administrator credentials once and uses them for all machines.

.COMPATIBILITY
This script requires PowerShell 5.1 or newer and administrative privileges.
It has been designed for use with Windows Server 2012 and later.

.NOTES
Script Name: Set-DomainTimeZone.ps1
Created By: TechBase IT
Version: 1.1

.EXAMPLE
.\Set-DomainTimeZone.ps1

This will prompt the user to select a time zone and apply it to all domain-joined machines.
#>

# Time zone options
$timeZones = @(
    'Hawaii Standard Time',
    'Alaskan Standard Time',
    'Pacific Standard Time',
    'Mountain Standard Time',
    'Arizona Standard Time',  # Arizona
    'Central Standard Time',
    'Eastern Standard Time'
)

# Display options
Write-Output "Please select a time zone by entering the corresponding number:"
for ($i=0; $i -lt $timeZones.Length; $i++) {
    Write-Output "$($i + 1): $($timeZones[$i])"
}

# Get user choice
$choice = Read-Host "Enter the number corresponding to your desired time zone"
$selectedTimeZone = $timeZones[$choice - 1]
Write-Output "You have selected: $selectedTimeZone"

# Prompt for credentials once
$global:credential = Get-Credential -Message "Enter domain admin credentials"

# Function to get all domain-joined computers
function Get-DomainComputers {
    Import-Module ActiveDirectory
    Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
}

# Function to set the time zone remotely
function Set-TimeZoneRemotely {
    param ($ComputerName, $TimeZone)

    Write-Output "[*] Setting time zone on ${ComputerName} to '$TimeZone'"

    try {
        Invoke-Command -ComputerName $ComputerName -Credential $global:credential -ScriptBlock {
            param ($tz)
            Start-Process -FilePath "powershell.exe" -ArgumentList "-Command Set-TimeZone -Name '$tz'" -Verb RunAs -Wait
        } -ArgumentList $TimeZone -ErrorAction Stop

        Write-Output "[+] Time zone successfully set on ${ComputerName}"
    }
    catch {
        Write-Output "[-] Failed to set time zone on ${ComputerName}: $($_.Exception.Message)"
    }
}

# Function to deploy time zone changes to all domain computers
function Deploy-TimeZone {
    $allComputers = Get-DomainComputers

    foreach ($computer in $allComputers) {
        Set-TimeZoneRemotely -ComputerName $computer -TimeZone $selectedTimeZone
    }
}

# Deploy the selected time zone to all domain-joined computers
Deploy-TimeZone

Write-Output "[*] Time zone configuration completed."