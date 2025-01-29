<#
.SYNOPSIS
This script allows the user to temporarily change the domain controller that a client is using for troubleshooting purposes.

.DESCRIPTION
The script interactively prompts the user to select a new domain controller from the available domain controllers in the domain.
It then changes the domain controller for the client to the selected one using the `nltest` command.

Please note that this change is temporary and should only be done for troubleshooting purposes.

.EXAMPLE
.\Change-DomainController.ps1
#>

function Format-DomainControllerInfo {
    param (
        [string]$domainControllerInfo
    )

    # Extract the relevant information from the lines
    $dcName = $domainControllerInfo -replace "DC: \\\\", ""

    # Format the output
    $output = "Domain Controller: $dcName"

    return $output
}

# Get the current domain name
$domain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).Name

# Get all available domain controllers in the domain
$domainControllers = Get-ADDomainController -Filter *
$availableDomainControllers = $domainControllers | Select-Object -ExpandProperty HostName

# Display the available domain controllers as options to the user
Write-Host "Available domain controllers in $($domain):"
for ($i = 0; $i -lt $availableDomainControllers.Count; $i++) {
    $number = $i + 1
    Write-Host "$number. $($availableDomainControllers[$i])"
}

# Prompt the user to select a domain controller
$selectedIndex = Read-Host "Enter the number of the domain controller to use (e.g., 1, 2, 3, etc.)"

# Check if the selected index is valid
if (-not $selectedIndex -or $selectedIndex -lt 1 -or $selectedIndex -gt $availableDomainControllers.Count) {
    Write-Host "Invalid selection. Please enter a valid number corresponding to the domain controller."
    exit
}

# Get the selected domain controller from the available list
$selectedDomainController = $availableDomainControllers[$selectedIndex - 1]

# Change the domain controller for the client to the selected one
Write-Host "Changing domain controller to $selectedDomainController..."
try {
    $result = nltest /Server:$env:COMPUTERNAME /SC_RESET:$domain\$selectedDomainController
    Write-Host "Domain controller changed successfully."
    Write-Host "Please note that this change is temporary and should only be used for troubleshooting purposes."
    Write-Host "The client will eventually revert to the original domain controller."
}
catch {
    Write-Host "Failed to change the domain controller. Please check your credentials and try again."
}
