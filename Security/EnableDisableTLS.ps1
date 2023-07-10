<#
.SYNOPSIS
    This script enables or disables Transport Layer Security (TLS) versions on Windows Server 2016, 2019, and 2022. 
.DESCRIPTION
    The script interacts with the user, asking if they wish to disable TLS 1.0 and 1.1 (checking their status first), 
    and if they wish to enable TLS 1.2 and 1.3 (again, checking their status first). The script requires at least PowerShell 5.1.
    It modifies the system's registry to enable or disable the specific TLS versions.
    WARNING: Modifying the system's registry can have significant effects on the system. Always ensure you have backup and recovery procedures in place.
.PARAMETER None
    This script doesn't take any parameters.
.EXAMPLE
    PS C:\> .\EnableDisableTLS.ps1
    Execution will prompt the user for their preferences regarding the status of TLS versions.
.NOTES
    Author: TechBase IT
    Last Updated: 2023-07-09
#>

# Ask the user if they would like to disable TLS 1.0 and 1.1
$disableOldTLS = Read-Host "Do you want to disable TLS 1.0 and 1.1? (yes/no)"

# If the user confirmed, disable TLS 1.0 and 1.1
if ($disableOldTLS -eq 'yes') {
    # Check if TLS 1.0 and 1.1 are enabled before disabling
    $tls10 = Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0'
    $tls11 = Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1'
    
    # Disable TLS 1.0 if it's enabled
    if ($tls10) {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'Enabled' -value '0'
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -name 'Enabled' -value '0'
    }

    # Disable TLS 1.1 if it's enabled
    if ($tls11) {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'Enabled' -value '0'
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'Enabled' -value '0'
    }
}

# Ask the user if they would like to enable TLS 1.2 and 1.3
$enableNewTLS = Read-Host "Do you want to enable TLS 1.2 and 1.3? (yes/no)"

# If the user confirmed, enable TLS 1.2 and 1.3
if ($enableNewTLS -eq 'yes') {
    # Check if TLS 1.2 and 1.3 are disabled before enabling
    $tls12 = Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2'
    $tls13 = Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3'
    
    # Enable TLS 1.2 if it's disabled
    if (-not $tls12) {
        New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force
        New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'Enabled' -value '1' –PropertyType 'DWORD'
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'DisabledByDefault' -value '0' –PropertyType 'DWORD'
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'Enabled' -value '1' –PropertyType 'DWORD'
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'DisabledByDefault' -value '0' –PropertyType 'DWORD'
    }

    # Enable TLS 1.3 if it's disabled (For Windows Server 2022 as TLS 1.3 is not natively supported on Windows Server 2016 or 2019)
    if (-not $tls13) {
        New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -Force
        New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client' -Force
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -name 'Enabled' -value '1' –PropertyType 'DWORD'
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -name 'DisabledByDefault' -value '0' –PropertyType 'DWORD'
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client' -name 'Enabled' -value '1' –PropertyType 'DWORD'
        New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client' -name 'DisabledByDefault' -value '0' –PropertyType 'DWORD'
    }
}