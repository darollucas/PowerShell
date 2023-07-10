<#
.SYNOPSIS
    The Set-OSCTakeOwnerShip function can add or remove 'Take OwnerShip' to/from the context menu. 

.DESCRIPTION
    The Set-OSCTakeOwnerShip function can add or remove 'Take OwnerShip' to/from the context menu.
    It modifies specific registry keys under HKEY_CLASSES_ROOT to add/remove the context menu command.
#>

Function Set-OSCTakeOwnerShip {
    param (
        # Flag to indicate if 'Take Ownership' should be added to the context menu
        [switch]$Add,

        # Flag to indicate if 'Take Ownership' should be removed from the context menu
        [Switch]$Remove
    )
    
    # Create a new PSDrive for the HKEY_CLASSES_ROOT registry hive
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null 
    
    # Check if the current user has Administrator rights
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You do not have Administrator rights to run this script! Please re-run this script as an Administrator!"
        return
    }
    
    # If the Remove flag is set, remove 'Take ownership' from the context menu
    if ($Remove) {
        # Check and remove 'Take ownership' from the context menu for files
        if (Test-Path -LiteralPath 'HKCR:\*\shell\runas') {
            Remove-Item -Path 'HKCR:\*\shell\runas' -Recurse -Confirm:$false
        }
        
        # Check and remove 'Take ownership' from the context menu for directories
        if (Test-Path -LiteralPath 'HKCR:\Directory\shell\runas') {
            Remove-Item -Path 'HKCR:\Directory\shell\runas' -Recurse -Confirm:$false
        }
        
        # Check and remove 'Take ownership' from the context menu for DLL files
        if (Test-Path -LiteralPath 'HKCR:\dllfile\shell\runas') {
            Remove-Item -Path 'HKCR:\dllfile\shell\runas' -Recurse -Confirm:$false
        }

        Write-Host "Removed 'Take ownership' from context menu successfully."
    }
    
    # If the Add flag is set, add 'Take ownership' to the context menu
    if ($Add) {
        # The command that will be run when 'Take ownership' is selected. It gives full permissions to the Administrators group.
        $command = 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F'

        # Add 'Take ownership' to the context menu for files
        if (!(Test-Path -Path 'HKCR:\*\shell\runas')) {
            New-Item -Path 'HKCR:\*\shell\runas' | Out-Null
            Set-ItemProperty -Path 'HKCR:\*\shell\runas' -Name '(default)' -Value 'Take Ownership'
            Set-ItemProperty -Path 'HKCR:\*\shell\runas' -Name 'NoWorkingDirectory' -Value ''
            New-Item -Path 'HKCR:\*\shell\runas' -Name 'Command' | Out-Null
            Set-ItemProperty -Path 'HKCR:\*\shell\runas\Command' -Name '(default)' -Value $command
        }

        # Add 'Take ownership' to the context menu for directories
        if (!(Test-Path -Path 'HKCR:\Directory\shell\runas')) {
            New-Item -Path 'HKCR:\Directory\shell\runas' | Out-Null
            Set-ItemProperty -Path 'HKCR:\Directory\shell\runas' -Name '(default)' -Value 'Take Ownership'
            Set-ItemProperty -Path 'HKCR:\Directory\shell\runas' -Name 'NoWorkingDirectory' -Value ''
            New-Item -Path 'HKCR:\Directory\shell\runas' -Name 'Command' | Out-Null
            Set-ItemProperty -Path 'HKCR:\Directory\shell\runas\Command' -Name '(default)' -Value $command
        }

        # Add 'Take ownership' to the context menu for DLL files
        if (!(Test-Path -Path 'HKCR:\dllfile\shell\runas')) {
            New-Item -Path 'HKCR:\dllfile\shell\runas' | Out-Null
            Set-ItemProperty -Path 'HKCR:\dllfile\shell\runas' -Name '(default)' -Value 'Take Ownership'
            Set-ItemProperty -Path 'HKCR:\dllfile\shell\runas' -Name 'NoWorkingDirectory' -Value ''
            New-Item -Path 'HKCR:\dllfile\shell\runas' -Name 'Command' | Out-Null
            Set-ItemProperty -Path 'HKCR:\dllfile\shell\runas\Command' -Name '(default)' -Value $command
        }

        Write-Host "Added 'Take ownership' to context menu successfully."
    }
}