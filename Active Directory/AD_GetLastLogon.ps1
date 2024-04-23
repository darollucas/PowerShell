<#
.SYNOPSIS
Displays last logon date of Active Directory user accounts and optionally exports the data to a CSV file.

.DESCRIPTION
This script retrieves and displays the last logon date for Active Directory user accounts. Users have the option to display all enabled user accounts or select specific users based on their names. There is also an option to export the displayed data to a CSV file.

.EXAMPLE
PS> .\Get-UserLastLogon.ps1

This command runs the script, displaying all enabled user accounts and their last logon dates, with an option to export.

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
        # Get specified users, ensuring case-insensitive comparison and trimming spaces
        foreach ($userName in $UserNames) {
            $trimmedName = $userName.Trim()
            $foundUsers = Get-ADUser -Property LastLogonDate -Filter "Enabled -eq 'True' -and Name -like '*$trimmedName*'" | Select-Object Name, LastLogonDate
            $userDetails += $foundUsers
        }
    }
    
    return $userDetails
}

# Main script logic
$allUsers = Read-Host "Do you want to display information for all users? (Y/N)"

if ($allUsers -eq 'Y' -or $allUsers -eq 'y') {
    $userDetails = Get-UserDetails
} else {
    $specificUserNames = Read-Host "Enter specific user names (comma-separated)"
    $userNamesArray = $specificUserNames.Split(',') | ForEach-Object { $_.Trim() }
    $userDetails = Get-UserDetails -UserNames $userNamesArray
}

# Display the user details
$userDetails | Format-Table -AutoSize

# Ask if the user wants to export the data to a CSV file
$exportCSV = Read-Host "Do you want to export the list to a CSV file? (Y/N)"
If ($exportCSV -eq 'Y' -or $exportCSV -eq 'y') {
    $csvPath = Read-Host "Enter the full path for the CSV file (e.g., C:\temp\lastlogon.csv)"
    $userDetails | Export-Csv -Path $csvPath -NoTypeInformation
    Write-Host "List exported to '$csvPath'." -ForegroundColor Green
} Else {
    Write-Host "Export canceled." -ForegroundColor Yellow
}
