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
