# Prompt for credentials once
$global:credential = Get-Credential -Message "Enter domain admin credentials to enable PowerShell Core remoting"

# Function to get all domain-joined computers
function Get-DomainComputers {
    Import-Module ActiveDirectory
    Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
}

# Function to enable PowerShell remoting on remote machines
function Enable-PowerShellRemoting {
    param ($ComputerName)

    Write-Output "[*] Enabling PowerShell Core remoting on ${ComputerName}"
    
    try {
        Invoke-Command -ComputerName $ComputerName -Credential $global:credential -ScriptBlock {
            # Ensure WinRM is running
            Start-Service WinRM -ErrorAction SilentlyContinue

            # Set network to private
            Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

            # Enable Windows PowerShell Remoting
            Enable-PSRemoting -Force -SkipNetworkProfileCheck

            # Enable PowerShell Core Remoting
            pwsh -Command "Enable-PSRemoting -SkipNetworkProfileCheck -Force"

            # Add firewall rules for WinRM
            New-NetFirewallRule -Name "WinRM_HTTP" -DisplayName "WinRM over HTTP" -Enabled True -Profile Any -Action Allow -Direction Inbound -Protocol TCP -LocalPort 5985
            New-NetFirewallRule -Name "WinRM_HTTPS" -DisplayName "WinRM over HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -Protocol TCP -LocalPort 5986
        } -ErrorAction Stop

        Write-Output "[+] PowerShell Core remoting enabled on ${ComputerName}"
    }
    catch {
        Write-Output "[-] Failed to enable PowerShell Core remoting on ${ComputerName}: $($_.Exception.Message)"
    }
}

# Function to deploy PowerShell Core remoting across all domain-joined computers
function Deploy-PSRemoting {
    $allComputers = Get-DomainComputers

    foreach ($computer in $allComputers) {
        Enable-PowerShellRemoting -ComputerName $computer
    }
}

# Deploy PowerShell Core remoting to all domain-joined computers
Deploy-PSRemoting

Write-Output "[*] PowerShell Core remoting setup completed."