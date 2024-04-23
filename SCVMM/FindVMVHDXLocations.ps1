<#
.SYNOPSIS
Lists VHDX file locations for VMs within a specified Hyper-V cluster managed by SCVMM.

.DESCRIPTION
This script connects to a specified SCVMM server, identifies a Hyper-V cluster managed by that SCVMM server, and attempts to list all VMs within that cluster. It then allows the user to specify a VM name to find its VHDX file locations.

.EXAMPLE
PS> .\FindVMVHDXLocations.ps1

Prompts for SCVMM server name, Hyper-V cluster name, attempts to list all VMs in the cluster, and then prompts for a specific VM name to list its VHDX file locations.

.NOTES
Author: TechBase IT
Date Created: 04/24/2024
Date Modified: 04/24/2024
Compatibility: PowerShell 5.1 and up, SCVMM 2022

#>

# Prompt for SCVMM server and Hyper-V cluster names
$scvmmServerName = Read-Host "Enter the SCVMM server name"
$hyperVClusterName = Read-Host "Enter the Hyper-V cluster name managed by SCVMM"

# Connect to the SCVMM server
try {
    Import-Module -Name VirtualMachineManager
    $scvmmServer = Get-SCVMMServer -ComputerName $scvmmServerName
} catch {
    Write-Error "Failed to connect to SCVMM server '$scvmmServerName'. Error: $_"
    exit
}

# Retrieve the specified Hyper-V cluster
$cluster = Get-SCVMHostCluster -Name $hyperVClusterName -VMMServer $scvmmServer

if (-not $cluster) {
    Write-Error "Hyper-V cluster '$hyperVClusterName' not found."
    exit
}

Write-Host "Retrieved Hyper-V cluster '$hyperVClusterName'. Searching for VMs..."

# Attempt to retrieve all VM hosts that are part of the specified cluster
$vmHosts = Get-SCVMHost -VMHostCluster $cluster

# List all VMs from those hosts
$vms = $vmHosts | ForEach-Object { Get-SCVirtualMachine -VMHost $_ }

if ($vms.Count -eq 0) {
    Write-Host "No VMs found in the cluster '$hyperVClusterName'."
} else {
    Write-Host "VMs found in the cluster '$hyperVClusterName':"
    $vms | ForEach-Object { Write-Host "`t$($_.Name)" }

    # Prompt for specific VM name and find VHDX locations
    $vmName = Read-Host "Enter the name of the VM to find VHDX file locations for"
    $selectedVM = $vms | Where-Object { $_.Name -eq $vmName }
    
    if ($selectedVM) {
        $vhdxFiles = $selectedVM | Get-SCVirtualHardDisk
        Write-Host "VHDX Files for VM '$vmName':"
        $vhdxFiles | ForEach-Object { Write-Host "`t$($_.Location)" }
    } else {
        Write-Host "VM '$vmName' not found in the cluster."
    }
}
