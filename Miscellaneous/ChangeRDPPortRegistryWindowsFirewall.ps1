<#
.SYNOPSIS
Changes the Remote Desktop Protocol (RDP) port on a Windows computer.

.DESCRIPTION
This script allows you to change the RDP port on a Windows computer. It checks if Remote Desktop is enabled, enables it if necessary, prompts the user to specify a new RDP port (default is 3389), updates the port in the registry, creates or updates the Windows Firewall rule for RDP, provides instructions for updating the port on the hardware firewall for external connections, and offers the option to restart the computer.

.NOTES
- Run this script with administrative privileges.

#>

# Check if Remote Desktop is enabled, and if not, give the option to enable it
$rdpEnabled = (Get-WmiObject -Class "Win32_TerminalServiceSetting" -Namespace "root\cimv2\terminalservices" -ErrorAction SilentlyContinue).AllowTSConnections
if (-not $rdpEnabled) {
    $enableRdp = Read-Host "Remote Desktop is currently disabled. Do you want to enable it? (Y/N)"
    if ($enableRdp -eq "Y" -or $enableRdp -eq "y") {
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
        Write-Host "Remote Desktop has been enabled."
    } else {
        Write-Host "Remote Desktop was not enabled. Exiting script."
        exit
    }
}

# Ensure Remote Desktop is allowed in the Windows Firewall
$rdpPort = Read-Host "Enter the new RDP port (default is 3389):"
if ([string]::IsNullOrWhiteSpace($rdpPort)) {
    $rdpPort = 3389
}

# Update the RDP port in the registry
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber" -Value $rdpPort

# Enable the Windows Firewall rule for RDP and set the port
$rdpFirewallRule = Get-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-In)" -ErrorAction SilentlyContinue
if ($rdpFirewallRule) {
    Set-NetFirewallRule -DisplayName $rdpFirewallRule.DisplayName -Enabled True -Action Allow -LocalPort $rdpPort
} else {
    New-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-In)" -Direction Inbound -Protocol TCP -LocalPort $rdpPort -Action Allow
}

# Inform the user about changing the port on the hardware firewall for external connections
Write-Host "The RDP port has been changed to $rdpPort in the registry and the Windows Firewall."

Write-Host "IMPORTANT: If you plan to use RDP from an external connection, make sure to update the port forwarding on your hardware firewall to forward incoming traffic on port $rdpPort to the internal IP address of your computer."

# Offer the option to restart the computer
$restartOption = Read-Host "Do you want to restart the computer now? (Y/N)"
if ($restartOption -eq "Y" -or $restartOption -eq "y") {
    Restart-Computer -Force
} else {
    Write-Host "The computer was not restarted. You may need to restart the computer for the changes to take full effect."
}