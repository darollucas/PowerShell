<#
.SYNOPSIS
This script searches the Active Directory (AD) for all disabled computer or user accounts and moves them to a specified Organizational Unit (OU).

.DESCRIPTION
The script prompts the user for all necessary information interactively.

.NOTES
Author: TechBase IT
#>

# Import ActiveDirectory module
if (-not(Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Active Directory module not found, installing now..."
    Install-WindowsFeature -Name RSAT-AD-Powershell
}

Import-Module ActiveDirectory

# Get target type
do {
    $Target = Read-Host "Enter the target type (Users or Computers)"
} while ($Target -notmatch "^(Users|Computers)$")

# Get domain
$Domain = Read-Host "Enter the domain (e.g., contoso.com)"

# Get OU details
$OUNames = Read-Host "Enter the names of the Organizational Units (OUs) where disabled accounts will be moved, from outermost to innermost, separated by commas (e.g., HR,Accounts,Disabled)"

# Construct DisabledOU using Domain and OU names
$OUPath = ($OUNames.Split(",") | ForEach-Object { "ou=$_" }) -join ','
$DisabledOU = "$OUPath,dc=$($Domain -replace '\.',',dc=')"

# Confirm Test Mode
$TestMode = (Read-Host "Run in Test Mode? (yes/no)") -eq 'yes'

# Determine if searching for disabled users or computers
$searchFilter = if ($Target -eq "Users") { "user" } else { "computer" }

# Get disabled objects based on target type
$disabledObjects = Get-ADObject -LDAPFilter "(&(objectCategory=$searchFilter)(userAccountControl:1.2.840.113556.1.4.803:=2))"

# Move disabled objects to DisabledOU
foreach ($obj in $disabledObjects) {
    try {
        if ($TestMode) {
            Write-Host "TEST MODE: Would move $($obj.Name)" -ForegroundColor Yellow
        } else {
            Move-ADObject -Identity $obj -TargetPath $DisabledOU -Confirm:$false
            Write-Host "Successfully moved $($obj.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Error moving $($obj.Name): $_"
    }
}