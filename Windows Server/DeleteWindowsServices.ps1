<#
.SYNOPSIS
This script interactively deletes services based on the provided display name.

.DESCRIPTION
The script prompts the user to enter the display name (or part of it) of the service they want to delete.
It searches for services with display names containing the user input and asks for confirmation before deleting them.

.INPUTS
None.

.OUTPUTS
None. The script displays the status of each service it attempts to delete.

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

# Prompt the user for the display name (or part of it) of the service they want to delete
$serviceName = Read-Host "Enter the display name (or part of it) of the service you want to delete"

# Get services with display names containing the user input
$services = Get-PartialServiceName -partialName $serviceName

if ($services.Count -eq 0) {
    Write-Output "No services found with the display name containing '$serviceName'."
} else {
    # Show the list of services to the user and ask for confirmation
    Write-Output "The following services will be deleted:"
    $services | ForEach-Object { $_.DisplayName }
    
    $confirmation = Read-Host "Are you sure you want to delete these services? (Y/N)"
    
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        # Loop through each service and attempt to delete it
        foreach ($service in $services) {
            try {
                # Stop the service before attempting to delete it
                if ($service.Status -eq "Running") {
                    Stop-Service $service.DisplayName -Force -Verbose
                }
                
                # Delete the service
                Get-WmiObject -Class Win32_Service | Where-Object { $_.DisplayName -eq $service.DisplayName } | ForEach-Object {
                    $_.Delete()
                    Write-Output "Deleted service $($service.DisplayName)."
                }
            } catch {
                Write-Output "Failed to delete service $($service.DisplayName). Error: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Output "Service deletion canceled."
    }
}
