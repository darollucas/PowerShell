<#
.SYNOPSIS
    This PowerShell script provides a menu-driven interface to install specific Remote Server Administration Tools (RSAT) on Windows 11.
.DESCRIPTION
    The script displays a menu for the user to select which RSAT tools to install. Options include individual tool installation, checking installed tools, or installing all tools.
#>

function Install-RSATTool {
    param (
        [string]$Name
    )
    Add-WindowsCapability -Online -Name $Name
}

function Show-Menu {
    param (
        [string]$Title = 'RSAT Installation Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    # Menu options in alphabetical order
    Write-Host "1: Install Active Directory DS-LDS Tools"
    Write-Host "2: Install BitLocker Recovery Tools"
    Write-Host "3: Install Certificate Services Tools"
    Write-Host "4: Install DHCP Tools"
    Write-Host "5: Install DNS Server Tools"
    Write-Host "6: Install Failover Cluster Management Tools"
    Write-Host "7: Install File Services Tools"
    Write-Host "8: Install Group Policy Management Tools"
    Write-Host "9: Install IPAM Client Tools"
    Write-Host "10: Install LLDP Tools"
    Write-Host "11: Install Network Controller Tools"
    Write-Host "12: Install Network Load Balancing Tools"
    Write-Host "13: Install Remote Access Management Tools"
    Write-Host "14: Install Remote Desktop Services Tools"
    Write-Host "15: Install Server Manager Tools"
    Write-Host "16: Install Shielded VM Tools"
    Write-Host "17: Install Storage Migration Service Management Tools"
    Write-Host "18: Install Storage Replica Tools"
    Write-Host "19: Install System Insights Management Tools"
    Write-Host "20: Install Volume Activation Tools"
    Write-Host "21: Install WSUS Tools"
}

# Hashtable mapping selection numbers to RSAT tool names
$toolNames = @{
    '1' = 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'
    '2' = 'Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0'
    '3' = 'Rsat.CertificateServices.Tools~~~~0.0.1.0'
    '4' = 'Rsat.DHCP.Tools~~~~0.0.1.0'
    '5' = 'Rsat.Dns.Tools~~~~0.0.1.0'
    '6' = 'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0'
    '7' = 'Rsat.FileServices.Tools~~~~0.0.1.0'
    '8' = 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0'
    '9' = 'Rsat.IPAM.Client.Tools~~~~0.0.1.0'
    '10' = 'Rsat.LLDP.Tools~~~~0.0.1.0'
    '11' = 'Rsat.NetworkController.Tools~~~~0.0.1.0'
    '12' = 'Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0'
    '13' = 'Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0'
    '14' = 'Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0'
    '15' = 'Rsat.ServerManager.Tools~~~~0.0.1.0'
    '16' = 'Rsat.Shielded.VM.Tools~~~~0.0.1.0'
    '17' = 'Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0'
    '18' = 'Rsat.StorageReplica.Tools~~~~0.0.1.0'
    '19' = 'Rsat.SystemInsights.Management.Tools~~~~0.0.1.0'
    '20' = 'Rsat.VolumeActivation.Tools~~~~0.0.1.0'
    '21' = 'Rsat.WSUS.Tools~~~~0.0.1.0'
}

# Main script execution starts here
do {
    Show-Menu -Title 'RSAT Installation Menu'
    
    $input = Read-Host "Please select an option (or multiple options separated by comma), C to Check installed RSAT tools, A to install All tools, or Q to Quit"
    
    if ($input -eq 'Q') {
        break
    }
    
    if ($input -eq 'C') {
        # Function to check installed RSAT tools would go here
        Read-Host "Press Enter to continue..."
        continue
    }
    
    if ($input -eq 'A') {
        # Function to install all RSAT tools would go here
        continue
    }

    $input.Split(',') | ForEach-Object {
        $selection = $_.Trim()
        if ($toolNames.ContainsKey($selection)) {
            Install-RSATTool -Name $toolNames[$selection]
        } else {
            Write-Host "Invalid selection: $selection"
        }
    }
    
    Read-Host "Press Enter to continue..."
} while ($true)
