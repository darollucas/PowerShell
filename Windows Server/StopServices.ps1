<#
.SYNOPSIS
This script interactively stops services in parallel based on the provided display name.

.DESCRIPTION
The script prompts the user to enter a display name (or part of it) of the service they want to stop.
It searches for services with display names containing the user input and attempts to stop them in parallel if they are not disabled.

.INPUTS
None.

.OUTPUTS
None. The script displays the status of each service it attempts to stop.

.NOTES
Author: TechBase IT (Modified to stop services in parallel)
#>

function Get-PartialServiceName {
    param (
        [string]$partialName
    )
    # Get all services with display names containing the provided partial name
    Get-Service | Where-Object { $_.DisplayName -like "*$partialName*" } | Select-Object Name, DisplayName, Status, StartType
}

# Prompt the user for the display name (or part of it) of the service they want to stop
$serviceName = Read-Host "Enter the display name (or part of it) of the service you want to stop"

# Get services with display names containing the user input
$services = Get-PartialServiceName -partialName $serviceName

if ($services.Count -eq 0) {
    Write-Output "No services found with the display name containing '$serviceName'."
} else {
    # Loop through each service and initiate a stop command as a background job if the service is running
    $jobs = @()
    foreach ($service in $services) {
        if ($service.Status -eq "Running") {
            $job = Start-Job -ScriptBlock {
                param($serviceName)
                Stop-Service -Name $serviceName -Force
            } -ArgumentList $service.Name
            $jobs += $job
            Write-Output "Initiated stop for service $($service.DisplayName)."
        } else {
            # If the service is not running, inform the user
            Write-Output "Service $($service.DisplayName) is not running. Skipping stop."
        }
    }

    # Wait for all jobs to complete
    $jobs | Wait-Job

    # Output each job's result
    foreach ($job in $jobs) {
        $result = Receive-Job -Job $job
        Remove-Job -Job $job
        Write-Output $result
    }
}