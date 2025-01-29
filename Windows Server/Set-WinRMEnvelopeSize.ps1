<#
.SYNOPSIS
This PowerShell script sets the MaxEnvelopeSizekb value for WinRM across all domain-joined machines.

.DESCRIPTION
The script retrieves a list of all domain-joined computers and remotely sets the MaxEnvelopeSizekb configuration to the specified value.
It prompts for domain administrator credentials once and applies the setting across all machines.

.COMPATIBILITY
This script requires PowerShell 5.1 or newer and administrative privileges.
It has been designed for use with Windows Server 2012 and later.

.NOTES
Script Name: Set-WinRMEnvelopeSize.ps1
Created By: TechBase IT
Version: 1.0

.EXAMPLE
.\Set-WinRMEnvelopeSize.ps1

This will update the MaxEnvelopeSizekb value to 600 across all domain-joined machines.
#>

# Define the envelope size value
$maxEnvelopeSize = 600

# Prompt for credentials once
$global:credential = Get-Credential -Message "Enter domain admin credentials"

# Function to get all domain-joined computers
function Get-DomainComputers {
    Import-Module ActiveDirectory
    Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
}

# Function to set the envelope size remotely
function Set-WinRMEnvelopeSizeRemotely {
    param ($ComputerName, $EnvelopeSize)

    Write-Output "[*] Setting MaxEnvelopeSizekb on ${ComputerName} to '$EnvelopeSize'"

    try {
        Invoke-Command -ComputerName $ComputerName -Credential $global:credential -ScriptBlock {
            param ($size)
            Set-WSManInstance -ResourceURI winrm/config -ValueSet @{MaxEnvelopeSizekb = $size}
        } -ArgumentList $EnvelopeSize -ErrorAction Stop

        Write-Output "[+] Successfully set MaxEnvelopeSizekb on ${ComputerName}"
    }
    catch {
        Write-Output "[-] Failed to set MaxEnvelopeSizekb on ${ComputerName}: $($_.Exception.Message)"
    }
}

# Function to deploy the setting to all domain computers
function Deploy-WinRMEnvelopeSize {
    $allComputers = Get-DomainComputers

    foreach ($computer in $allComputers) {
        Set-WinRMEnvelopeSizeRemotely -ComputerName $computer -EnvelopeSize $maxEnvelopeSize
    }
}

# Deploy the setting across all domain-joined computers
Deploy-WinRMEnvelopeSize

Write-Output "[*] WinRM envelope size configuration completed."