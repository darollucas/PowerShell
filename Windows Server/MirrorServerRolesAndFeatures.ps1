<#
.SYNOPSIS
Sync Windows Server Roles and Features across multiple servers using PowerShell Remoting.

.DESCRIPTION
This script synchronizes the roles and features of one or more target servers to match those of a source server. 
It supports Windows Server 2012 R2, 2016, 2019, 2022, and 2025. The script can also export the source server's 
roles and features to an XML file for later use. Additionally, it provides verbose output for detailed progress 
tracking and supports simulation mode to preview changes without applying them.

.NOTES
Script Name: Sync-WindowsRolesAndFeaturesRemotely.ps1
Created By: Your Name
Version: 2.0
Compatibility: PowerShell 5.1 and later
Supported OS: Windows Server 2012 R2, 2016, 2019, 2022, 2025

.EXAMPLE
PS> .\Sync-WindowsRolesAndFeaturesRemotely.ps1 -Source 'server1' -Targets 'comp1','comp2' -Verbose
# Synchronize 'comp1' and 'comp2' to match the roles and features of 'server1' with verbose output.

.EXAMPLE
PS> .\Sync-WindowsRolesAndFeaturesRemotely.ps1 -Source 'server1' -Targets 'comp1','comp2' -Simulate $true -Verbose
# Simulate the synchronization process to preview changes without applying them.

.EXAMPLE
PS> .\Sync-WindowsRolesAndFeaturesRemotely.ps1 -Source 'server1' -Targets 'comp1','comp2' -ExportXml $true -Verbose
# Synchronize target servers and export the source server's roles and features to an XML file.

.EXAMPLE
PS> .\Sync-WindowsRolesAndFeaturesRemotely.ps1 -Source 'C:\path\to\roles_features.xml' -Targets 'comp1','comp2' -Verbose
# Use a previously exported XML file as the source for synchronization.
#>

param (
    [string]$Source = '',
    [array]$Targets = @(),
    [bool]$Simulate = $false,
    [array]$InstallExclude = @(),
    [array]$RemoveExclude = @(),
    [bool]$ExportXml = $false,
    [string]$ExportFileName = 'roles_features'  # No extension, can be short or full path
)

# Enable strict mode and verbose output
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Function to retrieve roles and features from a server
function Get-RolesAndFeatures {
    param (
        [string]$ComputerName
    )
    Write-Verbose "Retrieving roles and features from $ComputerName..."
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Get-WindowsFeature | Select-Object Name, DisplayName, Installed, InstallState, FeatureType, Path, Depth, DependsOn, Parent, ServerComponentDescriptor, SubFeatures, AdditionalInfo
    }
}

# Function to synchronize roles and features on a target server
function Sync-RolesAndFeatures {
    param (
        [array]$SourceRolesAndFeatures,
        [array]$InstallExclude = @(),
        [array]$RemoveExclude = @(),
        [bool]$Simulate = $false
    )
    Write-Verbose "Starting synchronization on $env:COMPUTERNAME..."

    # Log the existing installed roles and features
    $logFilePath = Join-Path -Path $env:TEMP -ChildPath "$env:COMPUTERNAME`_roles_features_installed_$(Get-Date -Format 'yyyy-MM-dd_HH_mm_ss').txt"
    (Get-WindowsFeature | Where-Object { $_.Installed -eq $true }).Name | Out-File -FilePath $logFilePath
    Write-Verbose "Pre-change configuration logged to $logFilePath."

    $results = @()
    $sourceInstalled = ($SourceRolesAndFeatures | Where-Object { $_.Installed -eq $true }).Name
    $sourceRemoved = ($SourceRolesAndFeatures | Where-Object { $_.Installed -eq $false }).Name

    # Install missing roles and features
    foreach ($feature in $sourceInstalled) {
        $targetInstalled = (Get-WindowsFeature | Where-Object { $_.Installed -eq $true }).Name
        if ($targetInstalled -notcontains $feature -and $InstallExclude -notcontains $feature) {
            if ($Simulate) {
                Write-Verbose "[Simulation] Would install feature: $feature"
            } else {
                Write-Verbose "Installing feature: $feature"
                Install-WindowsFeature -Name $feature | Out-Null
            }
            $results += [PSCustomObject]@{
                Computername = $env:COMPUTERNAME
                Feature      = $feature
                Action       = 'Installed'
            }
        }
    }

    # Remove unnecessary roles and features
    foreach ($feature in $sourceRemoved) {
        $targetInstalled = (Get-WindowsFeature | Where-Object { $_.Installed -eq $true }).Name
        if ($targetInstalled -contains $feature -and $RemoveExclude -notcontains $feature) {
            if ($Simulate) {
                Write-Verbose "[Simulation] Would remove feature: $feature"
            } else {
                Write-Verbose "Removing feature: $feature"
                Remove-WindowsFeature -Name $feature | Out-Null
            }
            $results += [PSCustomObject]@{
                Computername = $env:COMPUTERNAME
                Feature      = $feature
                Action       = 'Removed'
            }
        }
    }

    return $results
}

# Main script logic
if (Test-Path -Path $Source -PathType Leaf) {
    Write-Verbose "Importing roles and features from XML file: $Source"
    $sourceResults = Import-Clixml -Path $Source
    $ExportXml = $false
} else {
    Write-Verbose "Retrieving roles and features from source server: $Source"
    $sourceResults = Get-RolesAndFeatures -ComputerName $Source
    if ($ExportXml) {
        $exportPath = "$ExportFileName.xml"
        Write-Verbose "Exporting source roles and features to $exportPath"
        $sourceResults | Export-Clixml -Path $exportPath -Depth 500
    }
}

# Synchronize roles and features on target servers
$syncResults = Invoke-Command -ComputerName $Targets -ScriptBlock ${function:Sync-RolesAndFeatures} -ArgumentList $sourceResults, $InstallExclude, $RemoveExclude, $Simulate -ThrottleLimit 5

# Output results
$syncResults | Format-Table -AutoSize