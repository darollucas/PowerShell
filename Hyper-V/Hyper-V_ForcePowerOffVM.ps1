<#
.SYNOPSIS
Forcefully powers off a virtual machine (VM) in Hyper-V.

.DESCRIPTION
This script allows you to forcefully power off a virtual machine in Hyper-V by terminating the associated 'vmwp.exe' process. It prompts the user to enter the name of the VM, retrieves the running process for that VM, and terminates the process to forcibly power off the VM.

.NOTES
Author: TechBase IT
Date: 2023-05-17

.LINK
Documentation: <link_to_documentation>

.EXAMPLE
PS> .\ForcefullyPowerOffVM.ps1
#>

$VMName = Read-Host "Enter the name of the VM"

# Retrieve the VM based on the provided name
$VM = Get-VM -Name $VMName

if ($null -eq $VM) {
    Write-Host "VM with name '$VMName' not found."
    exit
}

$VMGUID = $VM.ID

# Retrieve the running vmwp.exe process for the VM
$VMWPProc = Get-WmiObject -Class Win32_Process -Filter "Name = 'vmwp.exe' AND CommandLine LIKE '%$VMGUID%'"

if ($null -eq $VMWPProc) {
    Write-Host "Unable to find the running process for VM '$VMName'."
    exit
}

$VMWPProcID = $VMWPProc.ProcessId

# Forcefully stop the VM process
Stop-Process -Id $VMWPProcID -Force

Write-Host "The virtual machine '$VMName' has been forcefully powered off."
