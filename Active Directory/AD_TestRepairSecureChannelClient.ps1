<#
.SYNOPSIS
This PowerShell script tests and repairs the secure channel on a domain-joined machine. It prompts the user for the domain controller name and domain administrator credentials.

.DESCRIPTION
The script uses the Reset-ComputerMachinePassword and Test-ComputerSecureChannel cmdlets to check and repair the secure channel between the domain-joined machine and the domain controller. If the secure channel is broken, the script will reset the machine password and reboot the system.

.PARAMETER DomainController
The name of the domain controller to use for testing and repairing the secure channel.

.EXAMPLE
.\Test-RepairSecureChannel.ps1

#>

param (
    [Parameter(Mandatory = $true)]
    [string]$DomainController
)

# Prompt for domain administrator credentials
$Credential = Get-Credential -Message "Enter domain administrator credentials for $DomainController"

# Test the secure channel
Write-Host "Testing the secure channel between the local machine and $DomainController..."
$Result = Test-ComputerSecureChannel -Repair -Credential $Credential -Verbose

# If the secure channel is broken, repair it and reboot the system
if ($Result -eq $false) {
    Write-Warning "The secure channel is broken. Repairing the secure channel and rebooting the system..."
    Reset-ComputerMachinePassword -Server $DomainController -Credential $Credential -Force -Verbose
    Restart-Computer -Force
} else {
    Write-Host "The secure channel is healthy."
}
