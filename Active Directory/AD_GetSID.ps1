<#
.SYNOPSIS
This script provides options to get the SID of a domain user interactively.

.DESCRIPTION
The script allows the user to choose from multiple options to get the SID of a domain user.
It provides options to get the SID of a local user and get the SID for a domain user by prompting the user for the username.
Additionally, the script provides an option to find the username from a given SID.

.EXAMPLE
.\Get-UserSID.ps1
#>
function Get-LocalUserSID {
    param (
        [string]$UserName
    )
    try {
        $objUser = New-Object System.Security.Principal.NTAccount($UserName)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        Write-Output $strSID.Value
    }
    catch {
        Write-Error "Error getting SID for local user '$UserName': $_"
    }
}

function Get-DomainUserSID {
    param (
        [string]$UserName
    )
    try {
        $objUser = Get-ADUser -Identity $UserName
        Write-Output $objUser.SID.Value
    }
    catch {
        Write-Error "Error getting SID for domain user '$UserName': $_"
    }
}

function Find-UsernameFromSID {
    param (
        [string]$SID
    )
    try {
        $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
        $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
        Write-Output $objUser.Value
    }
    catch {
        Write-Error "Error finding username for SID '$SID': $_"
    }
}

# Prompt the user to select an option
Write-Host "Select an option to get the SID or a Username:"
Write-Host "1. Get the SID of a local user"
Write-Host "2. Get the SID of a domain user"
Write-Host "3. Get the username from a SID"
$choice = Read-Host "Enter the option number"

switch ($choice) {
    1 {
        $userName = Read-Host "Enter the local username"
        Get-LocalUserSID -UserName $userName
    }
    2 {
        $userName = Read-Host "Enter the domain username"
        Get-DomainUserSID -UserName $userName
    }
    3 {
        $SID = Read-Host "Enter the SID"
        Find-UsernameFromSID -SID $SID
    }
    default {
        Write-Error "Invalid option selected. Please select a valid option."
    }
}
