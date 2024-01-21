function Show-Menu {
    param (
        [string]$Title = 'RSAT Installation Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Install Active Directory DS-LDS Tools"
    Write-Host "2: Install File Services Tools"
    Write-Host "3: Install Group Policy Management Tools"
    Write-Host "4: Install IPAM Client Tools"
    Write-Host "5: Install LLDP Tools"
    Write-Host "6: Install Network Controller Tools"
    Write-Host "7: Install Network Load Balancing Tools"
    Write-Host "8: Install BitLocker Recovery Tools"
    Write-Host "9: Install Certificate Services Tools"
    Write-Host "10: Install DHCP Tools"
    Write-Host "11: Install Failover Cluster Management Tools"
    Write-Host "12: Install Remote Access Management Tools"
    Write-Host "13: Install Remote Desktop Services Tools"
    Write-Host "14: Install Server Manager Tools"
    Write-Host "15: Install Shielded VM Tools"
    Write-Host "16: Install Storage Migration Service Management Tools"
    Write-Host "17: Install Storage Replica Tools"
    Write-Host "18: Install System Insights Management Tools"
    Write-Host "19: Install Volume Activation Tools"
    Write-Host "20: Install WSUS Tools"
    Write-Host "A: Install all RSAT Tools"
    Write-Host "C: Check installed RSAT Tools"
    Write-Host "Q: Quit"
    Write-Host "==================================================="
}

function Install-RSATTool {
    param (
        [string]$Name
    )
    Add-WindowsCapability -Online -Name $Name
}

function Check-InstalledRSATTools {
    Get-WindowsCapability -Name RSAT* -Online | Where-Object {$_.State -eq 'Installed'} | Select-Object -Property Name, State
}

# Map user choice to the corresponding RSAT tool name
$toolNames = @{
    '1' = 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'
    '2' = 'Rsat.FileServices.Tools~~~~0.0.1.0'
    '3' = 'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0'
    '4' = 'Rsat.IPAM.Client.Tools~~~~0.0.1.0'
    '5' = 'Rsat.LLDP.Tools~~~~0.0.1.0'
    '6' = 'Rsat.NetworkController.Tools~~~~0.0.1.0'
    '7' = 'Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0'
    '8' = 'Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0'
    '9' = 'Rsat.CertificateServices.Tools~~~~0.0.1.0'
    '10' = 'Rsat.DHCP.Tools~~~~0.0.1.0'
    '11' = 'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0'
    '12' = 'Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0'
    '13' = 'Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0'
    '14' = 'Rsat.ServerManager.Tools~~~~0.0.1.0'
    '15' = 'Rsat.Shielded.VM.Tools~~~~0.0.1.0'
    '16' = 'Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0'
    '17' = 'Rsat.StorageReplica.Tools~~~~0.0.1.0'
    '18' = 'Rsat.SystemInsights.Management.Tools~~~~0.0.1.0'
    '19' = 'Rsat.VolumeActivation.Tools~~~~0.0.1.0'
    '20' = 'Rsat.WSUS.Tools~~~~0.0.1.0'
}

do {
    Show-Menu -Title 'RSAT Installation Menu'
    $input = Read-Host "Please select an option (or multiple options separated by comma)"
    
    if ($input -eq 'Q') {
        break
    }
    
    if ($input -eq 'C') {
        Check-InstalledRSATTools
        Read-Host "Press Enter to continue..."
        continue
    }
    
    if ($input -eq 'A') {
        Get-WindowsCapability -Name RSAT* -Online | Where-Object {$_.State -ne 'Installed'} | ForEach-Object {
            Install-RSATTool -Name $_.Name
        }
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
