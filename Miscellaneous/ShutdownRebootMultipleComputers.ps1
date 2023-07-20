<#
.SYNOPSIS
Shutdown or reboot multiple computers on a domain infrastructure.

.DESCRIPTION
This PowerShell script allows you to shutdown or reboot multiple computers on a domain infrastructure. You can specify the computer names and choose whether to perform a shutdown or reboot action.

.REQUIREMENTS AND PREREQUISITES
- The script should be executed from a computer that has administrative privileges on the target remote machines.
- Ensure you have proper network connectivity to reach the remote computers.
- The target remote computers should have PowerShell remoting enabled.
- Make sure you have permissions to shutdown or reboot remote computers.
- Ensure that you enter the correct computer names and that they are online and reachable.

.NOTES
- If the script encounters any issues, verify the infrastructure requirements and prerequisites mentioned above.
- Run this script with administrative privileges.
- Make sure you have proper permissions to shutdown or reboot remote computers.

#>

function Invoke-RemoteAction {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerNames,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Shutdown", "Reboot")]
        [string]$Action
    )

    foreach ($Computer in $ComputerNames) {
        if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
            if ($Action -eq "Shutdown") {
                Write-Host "Shutting down $Computer..."
                # The -f parameter forces an immediate shutdown without warning
                Invoke-Command -ComputerName $Computer -ScriptBlock { shutdown.exe /s /f /t 0 }
            } elseif ($Action -eq "Reboot") {
                Write-Host "Rebooting $Computer..."
                # The -f parameter forces an immediate reboot without warning
                Invoke-Command -ComputerName $Computer -ScriptBlock { shutdown.exe /r /f /t 0 }
            }
        } else {
            Write-Warning "Could not reach $Computer. Skipping..."
        }
    }
}

# Prompt user for computer names
$computers = Read-Host "Enter the names of the computers (separate multiple names with a comma):"
$computerNames = $computers -split ',' | ForEach-Object { $_.Trim() }

# Prompt user to choose shutdown or reboot
$actionChoice = Read-Host "Choose an action: (S)hutdown or (R)eboot"

# Validate the user's input for the action
if ($actionChoice -eq "S" -or $actionChoice -eq "s") {
    $action = "Shutdown"
} elseif ($actionChoice -eq "R" -or $actionChoice -eq "r") {
    $action = "Reboot"
} else {
    Write-Host "Invalid choice. Please enter either 'S' for Shutdown or 'R' for Reboot."
    exit
}

# Execute the remote action
Invoke-RemoteAction -ComputerNames $computerNames -Action $action