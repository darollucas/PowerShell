<#
.SYNOPSIS
    This script resizes the replica volume for a specified data source on a System Center Data Protection Manager (SCDPM) 2022 server.

.DESCRIPTION
    The script connects to the SCDPM 2022 server, retrieves the list of data sources, and allows the user to select a data source to resize the replica volume.
    The user is prompted to enter the new replica size in GB. The script then updates the replica size and logs the actions.

.NOTES
    Author: Your Name
    Version: 2.0
    Date: 2024-06-15

.PARAMETER DpmServer
    The name of the DPM server.

.PARAMETER LogFile
    The path to the log file where actions will be logged.
#>

param (
    [string]$DpmServer = $env:COMPUTERNAME,
    [string]$LogFile = "ResizeReplica.log"
)

# Initial Setup
$version = "2.0"
$ErrorActionPreference = "Stop"
[uint64]$GB = 1GB
$confirmPreference = "None"

# Function to display help information
function Show-Help {
    cls
    Write-Host "Version: $version" -ForegroundColor Cyan
    Write-Host "Script Usage" -ForegroundColor Green
    Write-Host "1. Lists all protected data sources and their current replica sizes." -ForegroundColor Green
    Write-Host "2. User selects a data source to resize the replica for." -ForegroundColor Green
    Write-Host "3. User enters the new replica size in GB." -ForegroundColor Green
    Write-Host "Actions and results are logged to $LogFile`n" -ForegroundColor White
}

# Log initial information
Add-Content -Path $LogFile -Value "**********************************"
Add-Content -Path $LogFile -Value "Version $version"
Add-Content -Path $LogFile -Value (Get-Date)
Show-Help

# User confirmation
$confirmation = Read-Host "`nThis script is intended for SCDPM 2022 or later. Press C to continue."
if ($confirmation -ne "C") {
    Write-Host "Exiting..."
    Exit 0
}

# Connect to DPM Server
Write-Host "Connecting to DPM server $DpmServer..."
$DPM = Connect-DPMServer -DpmServerName $DpmServer
if (-not $DPM) {
    Write-Host "Failed to connect to DPM server $DpmServer" -ForegroundColor Red
    Exit 1
}
Add-Content -Path $LogFile -Value "Connected to DPM server $DpmServer"

# Retrieve data sources
Write-Host "`nRetrieving list of data sources on $DpmServer`n" -ForegroundColor Green
$pgList = Get-ProtectionGroup -DPMServer $DPM
$dsList = @()
foreach ($pg in $pgList) {
    $dsList += Get-Datasource -ProtectionGroup $pg
}

# Display data sources
$i = 0
Write-Host "Index Protection Group     Computer             Path                                     Replica-Size (Bytes)"
Write-Host "-----------------------------------------------------------------------------------------------------------"
foreach ($ds in $dsList) {
    Write-Host ("[{0,3}] {1,-20} {2,-20} {3,-40} {4}" -f $i, $ds.ProtectionGroupName, $ds.Computer, $ds.Path, $ds.ReplicaSize)
    $i++
}

# User selects data source
$dsIndex = Read-Host "Enter the index of the data source to resize"
if ($dsIndex -lt 0 -or $dsIndex -ge $dsList.Count) {
    Write-Host "Invalid index" -ForegroundColor Red
    Exit 1
}
$selectedDS = $dsList[$dsIndex]
Add-Content -Path $LogFile -Value "Selected data source: $($selectedDS.ProtectionGroupName) - $($selectedDS.Computer) - $($selectedDS.Path)"

# User enters new replica size
$newReplicaSizeGB = Read-Host "Enter the new replica size in GB"
if (-not [uint64]::TryParse($newReplicaSizeGB, [ref]$null)) {
    Write-Host "Invalid size entered" -ForegroundColor Red
    Exit 1
}
$newReplicaSizeBytes = [uint64]$newReplicaSizeGB * $GB
Add-Content -Path $LogFile -Value "New replica size: $newReplicaSizeGB GB ($newReplicaSizeBytes Bytes)"

# Resize replica
Write-Host "Resizing replica for $($selectedDS.ProtectionGroupName) - $($selectedDS.Computer) - $($selectedDS.Path)..."
Resize-DPMReplica -Datasource $selectedDS -ReplicaSize $newReplicaSizeBytes
Add-Content -Path $LogFile -Value "Resized replica for $($selectedDS.ProtectionGroupName) to $newReplicaSizeBytes Bytes"

Write-Host "Replica resize completed successfully" -ForegroundColor Green