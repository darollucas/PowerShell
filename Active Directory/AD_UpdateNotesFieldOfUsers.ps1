<#
.SYNOPSIS
Updates the "Notes" field of Active Directory user accounts with a new comment, preserving existing comments.

.DESCRIPTION
This script adds a specified comment to the "Notes" (info attribute) field in Active Directory (AD) user accounts. It reads usernames from a provided CSV file, which should have a column named "Username". The new comment is added to the top of the existing notes to ensure that previous notes are preserved. This script is designed to be flexible and usable across different infrastructures.

.PARAMETER NewComment
The comment to be added to the "Notes" field of each user account.

.PARAMETER CSVFilePath
The path to the CSV file containing the usernames. The CSV should have a column named "Username".

.EXAMPLE
PS> .\UpdateADUserNotes.ps1 -NewComment "Verified on $(Get-Date -Format 'MM/dd/yyyy')" -CSVFilePath "C:\path\to\users.csv"
Updates the "Notes" field of user accounts listed in "users.csv" with the comment "Verified on [current date]".

.NOTES
Author: TechBase IT
Date Created: 04/24/2024
Date Modified: 04/24/2024
Compatible with PowerShell 5.1 and up.
Ensure the Active Directory module is installed and available.
This script requires running with administrative privileges to modify AD user properties.

.LINK
https://docs.microsoft.com/en-us/powershell/module/addsadministration/?view=windowsserver2022-ps

#>

param (
    [Parameter(Mandatory=$true)]
    [string]$NewComment,

    [Parameter(Mandatory=$true)]
    [string]$CSVFilePath
)

# Ensure the AD module is loaded
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "Active Directory module is not available. Please install this module to proceed."
    exit
}

# Import users from CSV
$Users = Import-Csv -Path $CSVFilePath

foreach ($user in $Users) {
    try {
        # Retrieve existing comments from the AD user
        $ADUser = Get-ADUser -Identity $user.Username -Properties info -ErrorAction Stop
        $ExistingComment = $ADUser.info

        # Combine new and existing comments
        $UpdatedComment = $NewComment + [Environment]::NewLine + $ExistingComment

        # Update the AD user's info attribute
        Set-ADUser -Identity $user.Username -Replace @{info = $UpdatedComment} -ErrorAction Stop

        Write-Host "Successfully updated notes for user: $($user.Username)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to update notes for user: $($user.Username). Error: $_"
    }
}
