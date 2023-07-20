<#
.SYNOPSIS
Disable Services Labeled as "Should Disable" on Windows Server 2016, 2019, and 2022.
This script is based on information from this link: Guidance on disabling system services on Windows Server 2016 with Desktop Experience
"https://learn.microsoft.com/en-us/windows-server/security/windows-services/security-guidelines-for-disabling-system-services-in-windows-server"


.DESCRIPTION
This PowerShell script disables the services labeled as "Should Disable" on Windows Server 2016, 2019, and 2022, based on Microsoft's security guidelines. 
These services are considered non-essential for a typical server environment, and disabling them can help improve security and performance.

.NOTES
- Run this script with administrative privileges.
- Before running the script, ensure you have a backup and a recovery plan in place in case any issues arise.
- Verify that the script is running on Windows Server 2016, 2019, or 2022 before executing.

#>

# Function to disable a Windows service
function Disable-Service {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ServiceName
    )

    try {
        Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction Stop
        Write-Host "Service $ServiceName has been disabled."
    } catch {
        Write-Warning "Failed to disable service $ServiceName. Error: $_"
    }
}

# List of services labeled as "Should Disable" from the provided link
$shouldDisableServices = @(
    "AppMgmt",
    "wbengine",
    "bthserv",
    "PeerDistSvc",
    "CertPropSvc",
    "DcpSvc",
    "DoSvc",
    "DPS",
    "TrkWks",
    "MSDTC",
    "DMWappushsvc",
    "EFS",
    "Fax",
    "FDResPub",
    "hkmsvc",
    "ICS",
    "iphlpsvc",
    "KtmRm",
    "netprofm",
    "CscService",
    "WPCSvc",
    "PcaSvc",
    "QWAVE",
    "RemoteRegistry",
    "RetailDemo",
    "RemoteAccess",
    "SensorDataService",
    "SENS",
    "SharedAccess",
    "ScDeviceEnum",
    "SCPolicySvc",
    "SNMPTRAP",
    "StorSvc",
    "TabletInputService",
    "UserDataSvc",
    "UserDataSvc_4dce0",
    "UevAgentService",
    "AudioEndpointBuilder",
    "wcncsvc",
    "wisvc",
    "WpnService",
    "WaaSMedicSvc",
    "XboxGipSvc",
    "XblAuthManager",
    "XblGameSave"
)

# Check if the script is running on Windows Server 2016, 2019, or 2022
$serverVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption
if ($serverVersion -match 'Windows Server 2016' -or $serverVersion -match 'Windows Server 2019' -or $serverVersion -match 'Windows Server 2022') {
    # Loop through the list and disable the services
    foreach ($service in $shouldDisableServices) {
        Disable-Service -ServiceName $service
    }
} else {
    Write-Warning "This script is intended to run on Windows Server 2016, 2019, or 2022 only."
}
