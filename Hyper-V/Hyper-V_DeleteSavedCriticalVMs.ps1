<#
.SYNOPSIS
This script is designed to help you remove a Hyper-V virtual machine (VM) that is stuck in a Saved-Critical state.

.DESCRIPTION
When a Hyper-V VM is in a Saved-Critical state and its files are no longer present, this can prevent normal management operations. This script will interactively guide you through the process of deleting such a VM from your Hyper-V server. It will ask for the VM's name, remove its saved state, and then delete the VM from the Hyper-V manager. This script is compatible with Windows Server 2016, 2019, and 2022.

.NOTES
Version:        1.0
Author:         TechBase IT
Creation Date:  02/04/2024
#>

# Ask for the name of the Hyper-V VM
$vmName = Read-Host "Please enter the name of the Hyper-V VM that is stuck in Saved-Critical state"

# Check if the VM exists
$vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue

if ($vm -eq $null) {
    Write-Host "VM with name '$vmName' does not exist." -ForegroundColor Red
    exit
}

# Check if the VM is in Saved state
if ($vm.State -eq 'Saved') {
    # Attempt to remove the saved state
    try {
        Remove-VMSavedState -VMName $vmName -Confirm:$false
        Write-Host "Saved state removed for VM '$vmName'." -ForegroundColor Green
    } catch {
        Write-Host "An error occurred while removing the saved state: $_" -ForegroundColor Red
    }
} else {
    Write-Host "VM '$vmName' is not in a saved state." -ForegroundColor Yellow
}

# Confirm deletion of the VM
$confirmDelete = Read-Host "Do you want to delete the VM '$vmName'? (Y/N)"
if ($confirmDelete -eq 'Y') {
    # Attempt to delete the VM
    try {
        Remove-VM -Name $vmName -Force -Confirm:$false
        Write-Host "VM '$vmName' has been deleted." -ForegroundColor Green
    } catch {
        Write-Host "An error occurred while deleting the VM: $_" -ForegroundColor Red
    }
} else {
    Write-Host "VM deletion cancelled." -ForegroundColor Yellow
}
