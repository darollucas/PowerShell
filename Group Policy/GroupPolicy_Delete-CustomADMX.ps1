<#
.SYNOPSIS
Deletes a custom ADMX file from the Central Store and its corresponding ADML file in the en-US subfolder.

.DESCRIPTION
An interactive PowerShell script that prompts the user for the name of the ADMX file to delete (even if it has already been deleted), navigates to the Central Store location, and removes the corresponding ADML file in the `en-US` subfolder. Designed for administrators managing custom ADMX and ADML files in Active Directory environments.

.EXAMPLE
PS> .\Delete-CustomADMX.ps1

Starts the script, navigates to the Central Store, and asks for the file name of the ADMX file to delete along with its corresponding ADML file.

.NOTES
Author: TechBase IT
Requires Administrator privileges. Ensure you have the necessary permissions before executing.
#>

# PowerShell Script to Delete a Custom ADMX File and its Corresponding ADML File

# Ensure the script is run with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator. Please restart PowerShell as Administrator." -ForegroundColor Red
    exit
}

# Define the Central Store location and the en-US subfolder
$CentralStorePath = "\\techbaseit.com\SYSVOL\techbaseit.com\Policies\PolicyDefinitions"
$EnUSFolderPath = Join-Path -Path $CentralStorePath -ChildPath "en-US"

# Check if the en-US subfolder exists
if (-not (Test-Path -Path $EnUSFolderPath)) {
    Write-Host "en-US subfolder not found: $EnUSFolderPath" -ForegroundColor Red
    exit
}

# Prompt the user for the ADMX file name
$FileName = Read-Host "Enter the name of the ADMX file (e.g., custom.admx) to delete its related files"

# Build paths for the ADMX and ADML files
$AdmxFilePath = Join-Path -Path $CentralStorePath -ChildPath $FileName
$AdmlFileName = [System.IO.Path]::ChangeExtension($FileName, ".adml")
$AdmlFilePath = Join-Path -Path $EnUSFolderPath -ChildPath $AdmlFileName

# Check and delete the ADMX file (if it exists)
if (Test-Path -Path $AdmxFilePath) {
    try {
        Remove-Item -Path $AdmxFilePath -Force
        Write-Host "Successfully deleted the ADMX file: $FileName" -ForegroundColor Green
    } catch {
        Write-Host "Failed to delete the ADMX file. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "ADMX file not found: $FileName (it might already have been deleted)" -ForegroundColor Yellow
}

# Check and delete the ADML file in the en-US subfolder
if (Test-Path -Path $AdmlFilePath) {
    try {
        Remove-Item -Path $AdmlFilePath -Force
        Write-Host "Successfully deleted the ADML file: $AdmlFileName" -ForegroundColor Green
    } catch {
        Write-Host "Failed to delete the ADML file. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Corresponding ADML file not found: $AdmlFileName (it might already have been deleted)" -ForegroundColor Yellow
}