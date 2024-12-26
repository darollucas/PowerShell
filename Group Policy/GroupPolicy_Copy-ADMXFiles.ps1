<#
.SYNOPSIS
    Copies and overwrites ADMX and ADML files to the Group Policy Central Store.

.DESCRIPTION
    This script automates the process of copying all .admx files from the specified source directory to the Central Store located in the SYSVOL folder on a domain controller. 
    It also ensures that .adml files (language-specific files) are copied to the appropriate "en-US" subfolder in the Central Store.

    The script uses the `Copy-Item` cmdlet with the `-Force` parameter to overwrite existing files in the central store. 
    It checks for administrative privileges and validates the existence of source and destination paths before proceeding.

.PARAMETER SourceADMXPath
    The path to the folder containing the .admx files to be copied.

.PARAMETER SourceADMLPath
    The path to the folder containing the .adml files (e.g., en-US subfolder).

.PARAMETER CentralStorePath
    The path to the central store's PolicyDefinitions folder in the SYSVOL share.

.PARAMETER CentralStoreENUSPath
    The path to the en-US subfolder in the central store.

.NOTES
    - This script must be run as Administrator.
    - Ensure that you have the necessary permissions on the SYSVOL folder to write to it.

.EXAMPLE
    .\Copy-ADMXFiles.ps1

    This will copy the ADMX and ADML files from the default source paths to the central store, overwriting existing files.

#>

# Define the source paths
$SourceADMXPath = "C:\Program Files (x86)\Microsoft Group Policy\Windows Server2025 November 2024 Update (24H2)\PolicyDefinitions"
$SourceADMLPath = Join-Path -Path $SourceADMXPath -ChildPath "en-US"

# Define the destination paths
$CentralStorePath = "\\techbaseit.com\SYSVOL\techbaseit.com\Policies\PolicyDefinitions"
$CentralStoreENUSPath = Join-Path -Path $CentralStorePath -ChildPath "en-US"

# Ensure the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator. Please restart PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Check if the source paths exist
if (-not (Test-Path -Path $SourceADMXPath)) {
    Write-Host "Source ADMX path does not exist: $SourceADMXPath" -ForegroundColor Red
    exit
}
if (-not (Test-Path -Path $SourceADMLPath)) {
    Write-Host "Source ADML path does not exist: $SourceADMLPath" -ForegroundColor Red
    exit
}

# Check if the destination paths exist
if (-not (Test-Path -Path $CentralStorePath)) {
    Write-Host "Central Store path does not exist: $CentralStorePath" -ForegroundColor Red
    exit
}
if (-not (Test-Path -Path $CentralStoreENUSPath)) {
    Write-Host "Central Store en-US path does not exist: $CentralStoreENUSPath" -ForegroundColor Red
    exit
}

# Copy ADMX files to the central store
Write-Host "Copying ADMX files to the Central Store..." -ForegroundColor Yellow
Get-ChildItem -Path $SourceADMXPath -Filter "*.admx" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $CentralStorePath -Force -ErrorAction Stop
}
Write-Host "ADMX files copied successfully." -ForegroundColor Green

# Copy ADML files to the en-US subfolder in the central store
Write-Host "Copying ADML files to the Central Store's en-US folder..." -ForegroundColor Yellow
Get-ChildItem -Path $SourceADMLPath -Filter "*.adml" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $CentralStoreENUSPath -Force -ErrorAction Stop
}
Write-Host "ADML files copied successfully." -ForegroundColor Green

Write-Host "All files have been copied and overwritten successfully." -ForegroundColor Cyan