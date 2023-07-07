<#
.SYNOPSIS
Locate Hyper-V Host FQDN.

.DESCRIPTION
This script locates the Fully Qualified Domain Name (FQDN) of a Hyper-V host. It prompts for a Hyper-V VM FQDN, performs a connectivity test, and retrieves the Hyper-V host FQDN remotely.

.NOTES
Script Name: Locate-HyperVHost.ps1
Created By: TechBase IT
Date: 07/07/2023
Version: 1.1

.EXAMPLE
.\Locate-HyperVHost.ps1
#>

# Function to check if the user wants to locate another VM
Function Prompt-Continue {
    $choice = Read-Host "Do you want to locate another Hyper-V VM? (Y/N)"
    return $choice.Trim().ToUpper()
}

# Clear the console window
Clear-Host

# Main loop
do {
    # Prompt for Hyper-V VM FQDN
    Write-Host "------------------------------" -ForegroundColor Yellow
    $vmVM = Read-Host -Prompt "Provide Hyper-V VM FQDN"

    # Validate the input
    if ([string]::IsNullOrWhiteSpace($vmVM)){
        Write-Warning "Name cannot be blank or contain spaces"
        break
    }

    # Perform connectivity test
    $pingResult = Test-Connection -ComputerName $vmVM -Quiet -Count 1

    if ($pingResult) {
        Write-Host "`tSuccessfully connected to [$vmVM]" -ForegroundColor Green
    } else {
        Write-Host "`tFailed to connect to [$vmVM]" -ForegroundColor Red
        Write-Host "`tTerminating script"
        Start-Sleep -Seconds 3
        break
    }

    # Retrieve Hyper-V host FQDN remotely
    Write-Host "(-) Processing..." -ForegroundColor Yellow

    $remoteCommand = {
        $rhost = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters").HostName
        $vm = $env:COMPUTERNAME
        $domain = $env:USERDNSDOMAIN
        $cfqdn = "$vm.$domain"

        Write-Host "`n++++++++++++++++++++++++++++++++++" -ForegroundColor Green
        Write-Host "Hyper-V Host   : [$rhost]"
        Write-Host "Hyper-V VM     : [$cfqdn]"
        Write-Host "++++++++++++++++++++++++++++++++++`n" -ForegroundColor Green
    }

    Invoke-Command -ComputerName $vmVM -ScriptBlock $remoteCommand

    # Prompt to continue
    $continue = Prompt-Continue
} while ($continue -eq "Y")

Write-Host "Thanks for using this script"