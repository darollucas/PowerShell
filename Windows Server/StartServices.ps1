<#
.SYNOPSIS
This script interactively starts services based on the provided display name.

.DESCRIPTION
The script prompts the user to enter a display name (or part of it) of the service they want to start.
It searches for services with display names containing the user input and attempts to start them if they are set to automatic.

.INPUTS
None.

.OUTPUTS
None. The script displays the status of each service it attempts to start.

.NOTES
Author: TechBase IT
#>

function Get-PartialServiceName {
    param (
        [string]$partialName
    )
    # Get all services with display names containing the provided partial name
    Get-Service | Where-Object { $_.DisplayName -like "*$partialName*" } | Select-Object DisplayName, Status, StartType
}

# Prompt the user for the display name (or part of it) of the service they want to start
$serviceName = Read-Host "Enter the display name (or part of it) of the service you want to start"

# Get services with display names containing the user input
$services = Get-PartialServiceName -partialName $serviceName

if ($services.Count -eq 0) {
    Write-Output "No services found with the display name containing '$serviceName'."
} else {
    # Loop through each service and check if it's set to automatic
    foreach ($service in $services) {
        if ($service.StartType -eq "Automatic") {
            # If the service is set to automatic, try starting it
            try {
                Start-Service $service.DisplayName -Verbose
                Write-Output "Started service $($service.DisplayName)."
            } catch {
                Write-Output "Failed to start service $($service.DisplayName). Error: $($_.Exception.Message)"
            }
        } elseif ($service.StartType -eq "Manual") {
            # If the service is set to manual, inform the user but don't attempt to start it
            Write-Output "Service $($service.DisplayName) is set to Manual. Skipping start."
        } else {
            # If the service is disabled, inform the user and don't attempt to start it
            Write-Output "Service $($service.DisplayName) is Disabled. Skipping start."
        }
    }
}
