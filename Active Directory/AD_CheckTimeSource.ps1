<#
.SYNOPSIS
This script queries each computer in the domain to determine its time source.

.DESCRIPTION
It must be run on a domain controller and requires the Active Directory PowerShell module. 
The script gets a list of all computers in the domain and runs the w32tm /query /source command for each one.

.COMPATIBILITY
This script is compatible with PowerShell 5.1 and higher. 

.NOTES
Script Name: TimeSourceQuery.ps1
Created By: TechBase IT
Version: 1.0
#>

# Import the Active Directory module. Script must exit if the module is not available
try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Host -ForegroundColor Red -BackgroundColor Black "***Active Directory PowerShell Module Not Found***"
    exit
}

# Define function to query time source for a single computer
function Get-TimeSource {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Computer
    )
    try {
        $tm_source = w32tm /query /computer:$Computer /source
        Write-Host "The time source for $Computer is $tm_source"
    }
    catch {
        Write-Host -ForegroundColor Red "Unable to query time source for $Computer"
    }
}

# Ask the user for their selection
$selection = Read-Host -Prompt "Enter 1 to check one computer, 2 to check multiple computers, or 3 to check all computers"

# Handle the user's selection
switch ($selection) {
    '1' {
        $computer = Read-Host -Prompt "Enter the name of the computer to check"
        Get-TimeSource -Computer $computer
    }
    '2' {
        $computers = Read-Host -Prompt "Enter the names of the computers to check, separated by commas"
        $computers.Split(',').Trim() | ForEach-Object {
            Get-TimeSource -Computer $_
        }
    }
    '3' {
        $computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
        $computers | ForEach-Object {
            Get-TimeSource -Computer $_
        }
    }
    default {
        Write-Host -ForegroundColor Red "Invalid selection"
    }
}