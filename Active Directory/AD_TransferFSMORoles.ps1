<#
.SYNOPSIS
Transfer or seize FSMO roles from one domain controller to another.

.DESCRIPTION
This PowerShell script allows you to transfer or seize specific FSMO (Flexible Single Master Operations) roles from one domain controller to another. It interactively prompts the user to select the FSMO role to transfer or seize and asks for the name of the target domain controller. The script then transfers or seizes the selected FSMO role(s) to the target domain controller.

.NOTES
- Run this script with administrative privileges.
- Transferring or seizing FSMO roles should be done with caution and only by experienced administrators.
#>

# Display the current FSMO roles
$CurrentFSMORoles = Get-ADDomain | Select-Object InfrastructureMaster, RIDMaster, PDCEmulator, DomainNamingMaster, SchemaMaster

Write-Host "Current FSMO Roles:"
$CurrentFSMORoles | Format-Table

# Prompt user to select the role to transfer or seize
$selectedRole = 0
do {
    Write-Host "Select the FSMO role to transfer or seize:"
    Write-Host "1. Infrastructure Master"
    Write-Host "2. RID Master"
    Write-Host "3. PDC Emulator"
    Write-Host "4. Domain Naming Master"
    Write-Host "5. Schema Master"
    Write-Host "6. All Roles"
    $selectedRole = Read-Host "Enter the number corresponding to the FSMO role or 'Q' to quit:"

    switch ($selectedRole) {
        "1" {
            $selectedRole = "InfrastructureMaster"
            break
        }
        "2" {
            $selectedRole = "RIDMaster"
            break
        }
        "3" {
            $selectedRole = "PDCEmulator"
            break
        }
        "4" {
            $selectedRole = "DomainNamingMaster"
            break
        }
        "5" {
            $selectedRole = "SchemaMaster"
            break
        }
        "6" {
            $selectedRole = "All"
            break
        }
        "Q" {
            Write-Host "Exiting the script."
            return
        }
        default {
            Write-Host "Invalid input. Please enter a valid number."
        }
    }
} while ($selectedRole -notin "InfrastructureMaster", "RIDMaster", "PDCEmulator", "DomainNamingMaster", "SchemaMaster", "All")

# Prompt user to enter the name of the target domain controller
$TargetDC = Read-Host "Enter the name of the target domain controller:"

# Check if the target domain controller exists
if (-not (Get-ADDomainController -Filter {Name -eq $TargetDC})) {
    Write-Host "Target domain controller '$TargetDC' does not exist."
    return
}

# Function to transfer or seize a specific FSMO role
function Move-FSMORole {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Role,
        [Parameter(Mandatory = $true)]
        [string]$Action,
        [Parameter(Mandatory = $true)]
        [string]$TargetDC
    )

    $forceAction = if ($Action -eq "Seize") { "-Force" } else { $null }

    Write-Host "$Action FSMO Role: $Role"
    if ($Action -eq "Seize") {
        Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole $Role -Force
    } else {
        Move-ADDirectoryServerOperationMasterRole -Identity $TargetDC -OperationMasterRole $Role
    }
}

# Transfer or seize the selected FSMO role(s)
switch ($selectedRole) {
    "All" {
        Write-Host "You selected to transfer or seize all roles."
        Write-Host "Transferring all FSMO roles to $TargetDC..."
        Move-FSMORole -Role "InfrastructureMaster" -Action "Transfer" -TargetDC $TargetDC
        Move-FSMORole -Role "RIDMaster" -Action "Transfer" -TargetDC $TargetDC
        Move-FSMORole -Role "PDCEmulator" -Action "Transfer" -TargetDC $TargetDC
        Move-FSMORole -Role "DomainNamingMaster" -Action "Transfer" -TargetDC $TargetDC
        Move-FSMORole -Role "SchemaMaster" -Action "Transfer" -TargetDC $TargetDC
    }
    default {
        Write-Host "You selected to transfer or seize a specific role."
        Move-FSMORole -Role $selectedRole -Action "Transfer" -TargetDC $TargetDC
    }
}

# Display the updated FSMO roles after the transfer or seizure
$UpdatedFSMORoles = netdom query fsmo | Out-String
Write-Host "Updated FSMO Roles:"
Write-Host $UpdatedFSMORoles