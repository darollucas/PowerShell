<#
.SYNOPSIS
Adds specified Active Directory computer objects to a designated group, offering options to select from a CSV file or manually enter object names.

.DESCRIPTION
This script adds selected Active Directory computer objects to a specified AD group. It prompts the user to choose between selecting object names from a provided CSV file or manually entering the names of the computer objects identified within the current domain. The script automatically identifies the working domain. If the specified group doesn't exist, it offers to create it based on user input. Designed for flexibility across different infrastructures.

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
    # Prompt the user to enter the computer names, comma-separated
    $computerNamesInput = Read-Host "Enter the computer object names you want to add to the group, separated by commas"
    $computerNames = $computerNamesInput -split ',' | ForEach-Object { $_.Trim() }

    # Retrieve AD computer objects based on user input
    $ADObjects = $computerNames | ForEach-Object {
        try {
            Get-ADComputer -Identity $_
        } catch {
            Write-Warning "Failed to find AD computer with name $_"
        }
    }
}

# Check if any ADObjects were retrieved or specified
if ($ADObjects.Count -eq 0) {
    Write-Error "No Active Directory computer objects were specified or found."
    exit
}

# Get or create the AD group
$groupName = Read-Host "Please enter the AD group name"
$group = Get-ADGroup -Filter { Name -eq $groupName } -ErrorAction SilentlyContinue

if (-not $group) {
    $createGroup = Read-Host "Group '$groupName' does not exist. Do you want to create it? (Y/N)"
    if ($createGroup.ToUpper() -eq 'Y') {
        New-ADGroup -Name $groupName -GroupScope Global -Path "CN=Users,DC=example,DC=com" # Adjust path as needed
        $group = Get-ADGroup $groupName
    } else {
        Write-Error "Group creation aborted by user."
        exit
    }
}

# Add computer objects to the group
foreach ($obj in $ADObjects) {
    try {
        Add-ADGroupMember -Identity $groupName -Members $obj.DistinguishedName -ErrorAction Stop
        Write-Host "Successfully added $($obj.Name) to $groupName."
    } catch {
        Write-Warning "Failed to add $($obj.Name) to ${groupName}: $_"
    }
}
