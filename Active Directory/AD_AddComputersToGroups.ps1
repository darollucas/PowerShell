<#
.SYNOPSIS
Adds specified Active Directory computer objects to a designated group, offering options to select from a CSV file or manually from domain-crawled results.

.DESCRIPTION
This script adds selected Active Directory computer objects to a specified AD group. It prompts the user to choose between selecting object names from a provided CSV file or manually from a list of all computer objects identified within the current domain. The script automatically identifies the working domain. If the specified group doesn't exist, it offers to create it based on user input. Designed for flexibility across different infrastructures.

.NOTES
Author: TechBase IT
Date Created: 04/24/2024
Date Modified: 04/24/2024
Compatible with PowerShell 5.1 and up.
Ensure the Active Directory module is installed and available.
Requires administrative privileges to modify AD object properties.

.LINK
https://docs.microsoft.com/en-us/powershell/module/addsadministration/?view=windowsserver2022-ps

#>

# Ensure the AD module is loaded
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "Active Directory module is not available. Please install this module to proceed."
    exit
}

# Prompt user for input method
$method = Read-Host "Do you want to crawl the domain for computers (D) or use a CSV file (C)? Enter 'D' for domain crawl or 'C' for CSV"

# Initialize variable
$ADObjects = @()

if ($method.ToUpper() -eq 'C') {
    # Prompt for CSV file path
    $CSVFilePath = Read-Host "Enter the full path to the CSV file"
    if (-not (Test-Path $CSVFilePath)) {
        Write-Error "CSV file path does not exist."
        exit
    }
    # Import AD objects from CSV
    $ADObjects = Import-Csv -Path $CSVFilePath | ForEach-Object { Get-ADComputer $_.Name }
} elseif ($method.ToUpper() -eq 'D') {
    # Automatically identify AD computer objects within the current domain
    $ADObjects = Get-ADComputer -Filter * -Property Name | Select-Object -Property Name
    # Display the objects and ask the user to select which ones to add
    $ADObjects | ForEach-Object { Write-Host "$($_.Name)" }
    $selectedNames = Read-Host "Enter the names of the computers to add to the group, separated by commas"
    $selectedNamesArray = $selectedNames -split ','
    $ADObjects = $selectedNamesArray.Trim() | ForEach-Object { Get-ADComputer $_ }
}

# Prompt for group name and check if it exists or needs to be created
$GroupName = Read-Host "Enter the AD group name"
$Group = Get-ADGroup -Filter { Name -eq $GroupName } -ErrorAction SilentlyContinue

if (-not $Group) {
    $createGroup = Read-Host "Group '$GroupName' does not exist. Do you want to create it? (Y/N)"
    if ($createGroup.ToUpper() -eq 'Y') {
        New-ADGroup -Name $GroupName -GroupScope Global -Path "CN=Users,$((Get-ADDomain).DistinguishedName)" -ErrorAction Stop
        Write-Host "Group '$GroupName' created successfully."
    } else {
        Write-Host "Exiting script."
        exit
    }
}

# Add selected computer objects to the group
foreach ($Object in $ADObjects) {
    try {
        Add-ADGroupMember -Identity $GroupName -Members $Object -ErrorAction Stop
        Write-Host "Added $($Object.Name) to $GroupName successfully."
    } catch {
        Write-Warning "Failed to add $($Object.Name) to ${GroupName}: $_"
    }
}