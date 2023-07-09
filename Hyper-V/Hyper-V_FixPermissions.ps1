<#
.SYNOPSIS
This PowerShell script modifies file permissions for Hyper-V related files, and creates a batch file to repair Hyper-V folder permissions.

.DESCRIPTION
This script first defines a variable containing the commands for a batch file intended to reset permissions on the Hyper-V directory. It then writes this batch file to the directory containing the PowerShell script.

The script retrieves a list of all .vhd and .vhdx files within the Hyper-V directory. For each of these files, it retrieves the existing Access Control List (ACL) and creates a new access rule granting specific permissions to the Virtual Machine (VM) associated with the file. The VM's Security Identifier (SID) is constructed using the name of the directory containing the file, which is assumed to match the VM's identifier.

Finally, the script adds the new access rule to the file's ACL, effectively granting the VM the specified permissions on the file.

The batch file and the permission updates allow for more secure and functional operation of Hyper-V VMs.

.COMPATIBILITY
This script requires PowerShell 3.0 or newer due to its use of cmdlets such as Get-ChildItem with the -File switch, and the $PSScriptRoot automatic variable. It has been designed specifically for use with Hyper-V on Windows Server 2012 and later.

.NOTES
Script Name: RepairHVPermissions.ps1
Created By: TechBase IT
Version: 1.0

.EXAMPLE
.\RepairHVPermissions.ps1

This will create the RepairHVPermissions.bat file in the same directory as the PowerShell script,
and update permissions on all .vhd and .vhdx files in the Hyper-V directory.
#>
$HyperVFolder = "C:\HyperV"  # Specify the Hyper-V folder path

# Define the repair script content
$RepairScript = @"
@Echo Off
icacls "$HyperVFolder" /grant "CREATOR OWNER":(OI)(CI)(IO)F
icacls "$HyperVFolder" /grant "NT AUTHORITY\SYSTEM":(OI)(CI)F

icacls "$HyperVFolder" /grant "NT VIRTUAL MACHINE\Virtual Machines":(RC,S,GR,RD,WD,AD,REA,RA)
icacls "$HyperVFolder" /grant "NT VIRTUAL MACHINE\Virtual Machines":(CI)(IO)(GR,WD,AD)

icacls "$HyperVFolder\Virtual Hard Disks" /grant "NT VIRTUAL MACHINE\Virtual Machines":(RC,S,GR,RD,WD,AD,REA,RA)
icacls "$HyperVFolder\Virtual Hard Disks" /grant "NT VIRTUAL MACHINE\Virtual Machines":(CI)(IO)(GR,WD,AD)
"@

$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "RepairHVPermissions.bat"

# Save the repair script to a .bat file
$RepairScript | Out-File -FilePath $ScriptPath -Encoding ASCII

# Retrieve VHD and VHDX files within the Hyper-V folder
$VHDFiles = Get-ChildItem -Path $HyperVFolder -Filter "*.vhd" -Recurse
$VHDXFiles = Get-ChildItem -Path $HyperVFolder -Filter "*.vhdx" -Recurse
$AllFiles = $VHDFiles + $VHDXFiles

# Iterate over each VHD and VHDX file to update permissions
foreach ($file in $AllFiles) {
    $vmID = $file.Directory.Name

    # Retrieve the existing ACL of the file
    $acl = Get-Acl -Path $file.FullName

    # Construct the VM SID and permission string
    $vmSID = "NT VIRTUAL MACHINE\$vmID"
    $permission = "ReadControl, Synchronize, GenericRead, ReadData, WriteData, AddFile, AppendData, ReadExtendedAttributes, WriteExtendedAttributes, ReadAttributes, WriteAttributes"

    # Create a new access rule for the VM and add it to the ACL
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($vmSID, $permission, "ContainerInherit, ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($rule)

    # Update the file ACL with the modified ACL
    Set-Acl -Path $file.FullName -AclObject $acl
}

Write-Host "RepairHVPermissions.bat created."
