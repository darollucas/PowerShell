<#
.SYNOPSIS
This script allows you to kill a Windows service that is stuck on stopping.

.DESCRIPTION
The script is interactive and prompts the user to type the service name. It then finds the PID (Process ID) of the service using the sc queryex command and kills the service using the taskkill command.

.PARAMETER None

.EXAMPLE
.\Kill-StuckService.ps1

#>

# Prompt the user to enter the service name
Write-Host "This script helps you kill a Windows service stuck on stopping."
$serviceName = Read-Host "Enter the name of the service you want to kill (case sensitive)"

try {
    # Get the service information using sc queryex
    Write-Verbose "Querying service information for $serviceName..."
    $serviceInfo = & sc.exe queryex $serviceName
    $servicePID = $serviceInfo | Select-String -Pattern "PID" -Context 0,1 | ForEach-Object { $_.Context.PostContext.Trim() }

    # Check if the service is in the "STOP_PENDING" state
    if ($serviceInfo -match "STOP_PENDING") {
        Write-Host "The service $serviceName is stuck on stopping with PID: $servicePID"
        
        # Prompt the user to confirm before killing the service
        $confirmation = Read-Host "Do you want to kill the service? (Y/N)"
        
        if ($confirmation -eq "Y") {
            # Kill the service using taskkill
            Write-Verbose "Terminating the service $serviceName with PID $servicePID..."
            & taskkill.exe /f /pid $servicePID
            Write-Host "The service $serviceName has been killed successfully."
        }
        else {
            Write-Host "Service termination aborted."
        }
    }
    else {
        Write-Host "The service $serviceName is not stuck on stopping."
    }
}
catch {
    Write-Host "Error occurred while trying to get service information. Please make sure the service name is correct."
}