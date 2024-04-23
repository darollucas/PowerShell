<#
.SYNOPSIS
Displays last logon date of Active Directory user accounts and optionally exports the data to a CSV file.

.DESCRIPTION
This script retrieves and displays the last logon date for Active Directory user accounts. Users have the option to display information for all enabled user accounts (A) or select specific users (S) based on their names. There is also an option to export the displayed data to a CSV file.

.EXAMPLE
PS> .\Get-UserLastLogon.ps1

This command runs the script, allowing the user to choose between displaying all enabled user accounts and their last logon dates or specifying users, with an option to export.

.NOTES
Author: TechBase IT
Date Created: 04/24/2024
Date Modified: 04/24/2024
Compatibility: PowerShell 5.1 and up
#>

# Function to get user details
function Get-UserDetails {
    param (
        [Parameter(Mandatory=$false)]
        [string[]]$UserNames
    )
    
    $userDetails = @()

    if ($UserNames -eq $null) {
        # Get all enabled users if no specific user names are provided
        $userDetails = Get-ADUser -Property LastLogonDate -Filter {Enabled -eq $true} | Select-Object Name, LastLogonDate
    } else {
        # Split the input string into an array of usernames, trimming spaces, and ensuring case-insensitive comparison
        $userNamesArray = $UserNames.Split(',')
        foreach ($userName in $userNamesArray) {
            $trimmedName = $userName.Trim()
            $foundUsers = Get-ADUser -Property LastLogonDate -Filter "Enabled -eq 'True' -and Name -like '*$trimmedName*'" | Select-Object Name, LastLogonDate
            if ($foundUsers) {
                $userDetails += $foundUsers
            }
        }
    }
    
    return $userDetails
}

# Main script logic
$userChoice = Read-Host "Do you want to display information for All Users (A) or Specific Users (S)?"

if ($userChoice -eq 'A') {
    $userDetails = Get-UserDetails
} elseif ($userChoice -eq 'S') {
    $specificUserNames = Read-Host "Enter specific user names (comma-separated)"
    $userDetails = Get-UserDetails -UserNames $specificUserNames
} else {
    Write-Host "Invalid choice. Exiting script." -ForegroundColor Red
    exit
}

# Display the list in the PowerShell window
$userDetails | Format-Table -AutoSize

# Ask the user if they want to export the list to a CSV file
$exportCSV = Read-Host "Do you want to export the list to a CSV file? (Y/N)"

if ($exportCSV -eq 'Y' -or $exportCSV -eq 'y') {
    $csvPath = Read-Host "Enter the full path for the CSV file (e.g., C:\temp\lastlogon.csv)"
    $userDetails | Export-Csv -Path $csvPath -NoTypeInformation
    Write-Host "List exported to '$csvPath'." -ForegroundColor Green
} else {
    Write-Host "Export canceled." -ForegroundColor Yellow
}