<#
.SYNOPSIS
This script interactively creates a Hyper-V SET virtual switch with user-defined configurations.

.DESCRIPTION
This script prompts the user to provide a switch name, the number of NICs to use, NIC names, and whether to allow the management OS to connect.
It then creates a Hyper-V SET virtual switch with the specified configurations.

.NOTES
Author: TechBase IT
Date: 08/14/2023

#>
# Prompt for switch name
$switchName = Read-Host "Enter the name of the virtual switch"

# Prompt for the number of NICs
$numNics = Read-Host "Enter the number of NICs you want to use"

# Initialize an array to store NIC names
$nicNames = @()

# Prompt for NIC names based on the number provided
for ($i = 1; $i -le $numNics; $i++) {
    $nicName = Read-Host "Enter the name of NIC $i"
    $nicNames += $nicName
}

# Prompt for AllowManagementOS
$allowManagementOS = Read-Host "Do you want to allow management OS to connect? (true/false)"

# Create the virtual switch
New-VMSwitch -Name $switchName -NetAdapterName $nicNames -EnableEmbeddedTeaming $true -AllowManagementOS $allowManagementOS
