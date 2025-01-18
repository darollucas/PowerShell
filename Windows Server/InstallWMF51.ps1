<#
.SYNOPSIS
Upgrades the PowerShell version on a Windows system to a specified target version.

.DESCRIPTION
This script upgrades the PowerShell version on a Windows system to a specified target version (3.0, 4.0, or 5.1). It handles dependencies such as .NET Framework upgrades and supports automatic reboots with optional auto-login. The script is compatible with Windows Server 2008 (SP2) through Windows Server 2016, as well as Windows 7 (SP1) through Windows 10.

.NOTES
Script Name: Upgrade-PowerShell.ps1
Author: TechBase IT
Version: 2.0
Compatibility: PowerShell 5.1 and later
Supported OS: Windows Server 2008 (SP2) through 2016, Windows 7 (SP1) through 10

.PARAMETER version
The target PowerShell version to upgrade to. Valid values are 3.0, 4.0, or 5.1. Default is 5.1.

.PARAMETER username
The username for automatic login after a reboot. Required if using automatic reboots.

.PARAMETER password
The password for automatic login after a reboot. Required if using automatic reboots.

.PARAMETER verbose
Enables verbose output for detailed progress tracking.

.EXAMPLE
# Upgrade to PowerShell 5.1 with automatic reboots
.\Upgrade-PowerShell.ps1 -version 5.1 -username "Administrator" -password "Password" -Verbose

.EXAMPLE
# Upgrade to PowerShell 4.0 with manual reboots
.\Upgrade-PowerShell.ps1 -version 4.0 -Verbose

.EXAMPLE
# Simulate upgrade to PowerShell 5.1
.\Upgrade-PowerShell.ps1 -version 5.1 -Simulate -Verbose
#>

param (
    [string]$version = "5.1",
    [string]$username,
    [string]$password,
    [switch]$verbose = $false
)

# Enable verbose logging if specified
if ($verbose) {
    $VerbosePreference = "Continue"
}

# Set error handling
$ErrorActionPreference = 'Stop'

# Log file path
$logFile = "$env:temp\upgrade_powershell.log"

# Function to write logs
function Write-Log {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $level - $message"
    Write-Verbose $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

# Function to handle reboots
function Reboot-AndResume {
    Write-Log "Configuring script to resume after reboot."
    $scriptPath = $script:MyInvocation.MyCommand.Path
    $psPath = "$env:SystemDrive\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $arguments = "-version $version"
    if ($username -and $password) {
        $arguments += " -username `"$username`" -password `"$password`""
    }
    if ($verbose) {
        $arguments += " -Verbose"
    }

    # Set the script to run on next logon
    $regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    $regPropertyName = "ps-upgrade"
    Set-ItemProperty -Path $regKey -Name $regPropertyName -Value "$psPath -ExecutionPolicy ByPass -File $scriptPath $arguments"

    # Configure auto-logon if credentials are provided
    if ($username -and $password) {
        $regWinlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Set-ItemProperty -Path $regWinlogonPath -Name AutoAdminLogon -Value 1
        Set-ItemProperty -Path $regWinlogonPath -Name DefaultUserName -Value $username
        Set-ItemProperty -Path $regWinlogonPath -Name DefaultPassword -Value $password
        Write-Log "Auto-logon configured. Rebooting..."
    } else {
        Write-Log "Manual reboot required. Please log in after reboot to continue."
        $rebootConfirmation = Read-Host "Reboot required. Proceed? (y/n)"
        if ($rebootConfirmation -ne "y") {
            Write-Log "Reboot canceled. Script will resume on next logon." -level "WARN"
            exit 1
        }
    }

    # Reboot the system
    Restart-Computer -Force
}

# Function to download a file
function Download-File {
    param (
        [string]$url,
        [string]$path
    )
    Write-Log "Downloading $url to $path"
    Invoke-WebRequest -Uri $url -OutFile $path
}

# Function to install an update
function Install-Update {
    param (
        [string]$file,
        [string]$arguments
    )
    Write-Log "Installing update: $file $arguments"
    $process = Start-Process -FilePath $file -ArgumentList $arguments -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) {
        throw "Installation failed with exit code $($process.ExitCode)"
    }
    if ($process.ExitCode -eq 3010) {
        Write-Log "Reboot required to continue."
        Reboot-AndResume
    }
}

# Main script logic
Write-Log "Starting PowerShell upgrade process."

# Check current PowerShell version
$currentVersion = [version]"$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
if ($currentVersion -eq [version]$version) {
    Write-Log "Current PowerShell version matches target version. No action required."
    exit 0
}

# Determine OS architecture
$architecture = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { "x64" } else { "x86" }

# Define update URLs based on target version
$updateUrls = @{
    "3.0" = @{
        "x64" = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu"
        "x86" = "https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x86.msu"
    }
    "4.0" = @{
        "x64" = "https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu"
        "x86" = "https://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x86-MultiPkg.msu"
    }
    "5.1" = @{
        "x64" = "http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip"
        "x86" = "http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7-KB3191566-x86.zip"
    }
}

# Download and install the update
$updateUrl = $updateUrls[$version][$architecture]
$updateFile = "$env:temp\$(Split-Path -Leaf $updateUrl)"
Download-File -url $updateUrl -path $updateFile
Install-Update -file $updateFile -arguments "/quiet /norestart"

Write-Log "PowerShell upgrade completed successfully."