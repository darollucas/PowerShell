<#
.SYNOPSIS
Searches domain computers for a specific user or AD group within a specified local group and optionally exports the results.

.DESCRIPTION
This script prompts the user to search for either a specific username or an AD group within a specified local group across all domain computers. It checks if the specified user or any member of the specified AD group is a part of the specified local group on each computer. The user has an option to export the results to a CSV file.

.EXAMPLE
PS> .\FindUserOrGroupInLocalGroup.ps1

This command runs the script, prompting the user for necessary input and then performing the search based on that input.

.NOTES
Author: TechBase IT
Date Created: 04/24/2024
Date Modified: 04/24/2024
Compatibility: PowerShell 5.1 and up
#>

# Prompt for user input
$searchType = Read-Host "Search for a User (U) or an AD Group (G)?"
$identityToSearch = Read-Host "Enter the username or AD group name to search for"
$GroupToSearch = Read-Host "Enter the local group name to search within"
$ComputersFound = @()

# Function to get members of an AD group
function Get-ADGroupMembers {
    param (
        [string]$GroupName
    )
    try {
        $groupMembers = Get-ADGroupMember -Identity $GroupName -Recursive | Select-Object -ExpandProperty SamAccountName
        return $groupMembers
    } catch {
        Write-Warning "Failed to retrieve members of AD group '$GroupName'. Ensure the group exists and you have necessary permissions."
        return $null
    }
}

# Initialize searcher for domain computers
$Searcher = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$Searcher.Filter = "(objectClass=computer)"

# Search each domain computer
foreach ($Computer in $Searcher.FindAll()) {
    $Path = $Computer.Path
    $Name = ([ADSI]"$Path").Name

    Write-Host "Checking $Name..." -ForegroundColor Green
    
    if (Test-Connection $Name -Count 1 -Quiet) {
        try {
            $members = ([ADSI]"WinNT://$Name/$GroupToSearch,group").psbase.Invoke("Members") | ForEach-Object {
                $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
            }

            if ($searchType -eq "U" -and $identityToSearch -in $members) {
                Write-Host "$identityToSearch is a member of $GroupToSearch on $Name" -ForegroundColor Yellow
                $ComputersFound += $Name
            } elseif ($searchType -eq "G") {
                $adGroupMembers = Get-ADGroupMembers -GroupName $identityToSearch
                if ($adGroupMembers -ne $null) {
                    foreach ($member in $adGroupMembers) {
                        if ($member -in $members) {
                            Write-Host "A member of AD group '$identityToSearch' is a member of $GroupToSearch on $Name" -ForegroundColor Yellow
                            $ComputersFound += $Name
                            break
                        }
                    }
                }
            }
        } catch {
            Write-Error "Error accessing group members on $Name"
        }
    } else {
        Write-Host "$Name is not online" -ForegroundColor Red
    }
}

# Optional export to CSV
if ($ComputersFound.Count -gt 0) {
    $exportCSV = Read-Host "Do you want to export the list to a CSV file? (Y/N)"
    if ($exportCSV -eq 'Y' -or $exportCSV -eq 'y') {
        $csvPath = Read-Host "Enter the full path for the CSV file (e.g., C:\temp\foundComputers.csv)"
        $ComputersFound | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Host "Results exported to '$csvPath'." -ForegroundColor Green
    }
} else {
    Write-Host "No matches found." -ForegroundColor Yellow
}