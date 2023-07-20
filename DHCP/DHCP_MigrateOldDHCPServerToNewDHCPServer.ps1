<#
.SYNOPSIS
This script migrates the DHCP configuration, leases, logs, and backups from the old DHCP server to the new DHCP server.

.DESCRIPTION
The script should be run from the new DHCP Server. The script prompts the user to enter the name of the old DHCP server and the name of the new DHCP server. It then performs the following steps:
1. Backs up the old DHCP server configuration.
2. Exports the DHCP configuration and leases from the old server.
3. Imports the DHCP configuration and leases to the new server.
4. Copies the DHCP logs and backups from the old server to the new server.
5. Unauthorizes the old DHCP server.
6. Authorizes the new DHCP server.

.PARAMETER None

.NOTES
Script Name: DHCPMigration.ps1
Created By: TechBase IT
Version: 1.0

.EXAMPLE
.\DHCPMigration.ps1
# Prompts the user to enter the old DHCP server name and the new DHCP server name, and performs the migration.

#>

# Prompt the user to enter the name of the old DHCP server
$oldDhcpServer = Read-Host -Prompt "Enter the name of the old DHCP server"

# Prompt the user to enter the name of the new DHCP server
$newDhcpServer = Read-Host -Prompt "Enter the name of the new DHCP server"

# Define the paths to the backup and export files
$backupPath = "C:\DHCPMigdata\DHCPBackup"
$exportFilePath = "C:\DHCPMigdata\DHCPdata.xml"

# Backup the old DHCP server
Backup-DhcpServer -ComputerName $oldDhcpServer -Path $backupPath -Force

# Export the DHCP configuration and leases from the old server
Export-DhcpServer -ComputerName $oldDhcpServer -File $exportFilePath -Leases -Force

# Import the DHCP configuration and leases to the new server
Import-DhcpServer -ComputerName $newDhcpServer -File $exportFilePath -BackupPath $backupPath -Leases -ScopeOverwrite -Force

# Copy the DHCP logs and backups from the old server to the new server
$dhcpLogPath = "\\$oldDhcpServer\c$\Windows\System32\dhcp"
$dhcpBackupPath = "\\$oldDhcpServer\c$\Windows\System32\dhcp\backup"

if (Test-Path $dhcpLogPath) {
    Copy-Item -Path $dhcpLogPath -Destination "\\$newDhcpServer\c$\Windows\System32\dhcp" -Recurse -Force
}

if (Test-Path $dhcpBackupPath) {
    Copy-Item -Path $dhcpBackupPath -Destination "\\$newDhcpServer\c$\Windows\System32\dhcp\backup" -Recurse -Force
}

# Unauthorize the old DHCP server
Remove-DhcpServerInDC -DnsName $oldDhcpServer -Force

# Authorize the new DHCP server
Add-DhcpServerInDC -DnsName $newDhcpServer -Force