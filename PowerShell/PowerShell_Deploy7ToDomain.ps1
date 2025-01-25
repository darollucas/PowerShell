<#
.SYNOPSIS
This PowerShell script deploys PowerShell Core to all domain-joined machines.

.DESCRIPTION
The script retrieves a list of all domain-joined computers and remotely installs PowerShell Core.
It prompts for domain administrator credentials once and applies the installation across all machines.
If PowerShell Core is already installed and remoting is enabled, it will skip the installation.

.COMPATIBILITY
This script requires PowerShell 5.1 or newer and administrative privileges.
It has been designed for use with Windows Server 2012 and later.

.NOTES
Script Name: Deploy-PowerShellCore.ps1
Created By: TechBase IT
Version: 1.0

.EXAMPLE
.\Deploy-PowerShellCore.ps1

This will install PowerShell Core on all domain-joined machines.
#>

# Define PowerShell Core installation details
$installerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.5.0/PowerShell-7.5.0-win-x64.msi"
$installerPath = "C:\Temp\PowerShell-7.5.0-win-x64.msi"

# Prompt for credentials once
$global:credential = Get-Credential -Message "Enter domain admin credentials to deploy PowerShell Core"

# Function to get all domain-joined computers
function Get-DomainComputers {
    Import-Module ActiveDirectory
    Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
}

# Function to check if PowerShell Core is installed and remoting enabled
function Check-PowerShellCore {
    param ($ComputerName)
    try {
        $result = Invoke-Command -ComputerName $ComputerName -Credential $global:credential -ScriptBlock {
            if (Get-Command pwsh -ErrorAction SilentlyContinue) {
                if (Test-WSMan -ErrorAction SilentlyContinue) {
                    return $true
                }
            }
            return $false
        } -ErrorAction Stop
        return $result
    }
    catch {
        Write-Output "[-] Failed to check PowerShell Core on ${ComputerName}: $($_.Exception.Message)"
        return $false
    }
}

# Function to install PowerShell Core remotely and enable remoting
function Install-PowerShellCore {
    param ($ComputerName)

    Write-Output "[*] Checking PowerShell Core installation on ${ComputerName}"
    if (Check-PowerShellCore -ComputerName $ComputerName) {
        Write-Output "[+] PowerShell Core is already installed and remoting is enabled on ${ComputerName}. Skipping installation."
        return
    }

    Write-Output "[*] Installing PowerShell Core on ${ComputerName}"

    try {
        Invoke-Command -ComputerName $ComputerName -Credential $global:credential -ScriptBlock {
            param ($url, $path)

            # Create temp directory if it doesn't exist
            if (-not (Test-Path "C:\Temp")) {
                New-Item -ItemType Directory -Path "C:\Temp" | Out-Null
            }

            # Download PowerShell Core
            Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
            
            # Silent install
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $path /qn" -Wait
            
            # Enable PowerShell Core remoting
            pwsh -Command "Enable-PSRemoting -SkipNetworkProfileCheck -Force"
            
            # Clean up the installer
            Remove-Item $path -Force

            Write-Output "[+] PowerShell Core installed and remoting enabled on $env:COMPUTERNAME"
        } -ArgumentList $installerUrl, $installerPath -ErrorAction Stop

        Write-Output "[+] PowerShell Core installed and remoting enabled on ${ComputerName}"
    }
    catch {
        Write-Output "[-] Failed to install PowerShell Core on ${ComputerName}: $($_.Exception.Message)"
    }
}

# Function to deploy PowerShell Core across all domain-joined computers
function Deploy-PowerShellCore {
    $allComputers = Get-DomainComputers

    foreach ($computer in $allComputers) {
        Install-PowerShellCore -ComputerName $computer
    }
}

# Deploy PowerShell Core to all domain-joined computers
Deploy-PowerShellCore

Write-Output "[*] PowerShell Core deployment completed."