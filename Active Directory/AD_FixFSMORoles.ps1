<#
.SYNOPSIS
This script checks and fixes the Flexible Single Master Operations (FSMO) roles in an Active Directory environment.

.DESCRIPTION
The script verifies the FSMO roles at both the forest and domain levels. It checks if the role owners are accessible and corrects any inconsistencies found. The script requires the Active Directory module to be imported. It logs the output messages to a file and displays them on the console.

.NOTES
Script Name: FixFSMORoles.ps1
Created By: TechBase IT
Version: 1.0

.EXAMPLE
.\Check-FSMORoles.ps1
# Run the script to check and fix the FSMO roles in the Active Directory environment.

#>

# Check if the Active Directory module is imported, if not, import it
$ADModule = Get-Module -ListAvailable | Where-Object { $_.Name -eq 'ActiveDirectory' }
if (-not $ADModule) {
    Import-Module ActiveDirectory
}

# Function to write output messages with different colors and log to a file
Function Write-OutputWithColor {
    Param(
        [Parameter(Mandatory=$true)]  
        [String]$String,
        [Parameter(Mandatory=$false)]  
        [String]$Color = "White"
    )
    Write-Host $String -ForegroundColor $Color
    $String | Out-File -FilePath $Script:LogFile -Append
}

# Function to check and fix FSMO roles
Function Check-FSMORoles {
    # Get the forest information
    $ForestInfo = Get-ADForest
    
    # Initialize variables
    $BrokenRoles = @()
    $Checked = @()

    # Display forest-level FSMO roles
    Write-OutputWithColor "Forest-level FSMO roles:`n`n"
    # Check and display the Schema Master role
    # ...

    # Check and display the Domain Naming Master role
    # ...

    # Get application partitions
    $Partitions = $ForestInfo | Select-Object -ExpandProperty ApplicationPartitions

    # Get domains
    $Domains = $ForestInfo | Select-Object -ExpandProperty Domains

    Write-OutputWithColor "Domain-level FSMO roles:`n"

    # Iterate through each domain
    foreach ($Domain in $Domains) {
        Write-OutputWithColor "Domain:`t$($Domain)`n"
        $DomainInfo = Get-ADDomain $Domain
        # Check and display the PDC Emulator role
        # ...

        # Check and display the RID Master role
        # ...

        # Check and display the Infrastructure Master role
        # ...

        # Check and display the application partition FSMO roles
        # ...

        # Mark the domain as checked
        $Checked += $DomainInfo.DistinguishedName
    }

    # Check and display the Naming Context FSMO roles
    # ...

    # Iterate through the broken roles and fix them
    if ($BrokenRoles) {
        foreach ($Faulty in $BrokenRoles) {
            Write-OutputWithColor "Faulty fSMO Role Owner set at:`n$($Faulty.FQDN).`n"
            # Fix the faulty role owner
            # ...
        }
    } else {
        Write-OutputWithColor "No faulty fSMO Role Owners found.`n"
    }
}

# Main script
$LogFilePath = "C:\Temp\Logs\FixFSMORoles.log"

# Initialize the log file path
$Script:LogFile = $LogFilePath

# Create the folder path if it doesn't exist
$Folder = Split-Path $Script:LogFile
if (-not (Test-Path $Folder)) {
    New-Item -ItemType Directory -Path $Folder | Out-Null
}

# Clear the log file if it exists
if (Test-Path $Script:LogFile) {
    Clear-Content $Script:LogFile
}

# Start the FSMO roles check
Write-OutputWithColor "Starting FSMO roles check..."

# Call the function to check and fix FSMO roles
Check-FSMORoles

# Complete the FSMO roles check
Write-OutputWithColor "FSMO roles check completed."
