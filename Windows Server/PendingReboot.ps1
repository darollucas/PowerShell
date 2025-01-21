<#
.SYNOPSIS
    Determines if a local or remote computer is pending a reboot and provides an interactive option to reboot the machine(s).

.DESCRIPTION
    This function checks various registry keys and WMI classes to determine if a computer is pending a reboot. It checks for:
    - Component-Based Servicing (CBS) reboots (Windows 2008+).
    - Windows Update reboots (Windows 2003+).
    - SCCM 2012 Client SDK reboots.
    - Pending computer rename or domain join operations.
    - Pending file rename operations.

    After identifying pending reboots, the script provides an interactive prompt to reboot specific machines or all machines with pending reboots.

.PARAMETER ComputerName
    Specifies the computer(s) to check. Defaults to the local computer.

.PARAMETER ErrorLog
    Specifies a file path to log errors encountered during execution.

.EXAMPLE
    PS C:\> Get-PendingReboot -ComputerName "Server01", "Server02"

    Computer      : Server01
    CBServicing   : False
    WindowsUpdate : True
    CCMClientSDK  : False
    PendComputerRename : False
    PendFileRename : False
    PendFileRenVal : 
    RebootPending : True

    Computer      : Server02
    CBServicing   : False
    WindowsUpdate : False
    CCMClientSDK  : False
    PendComputerRename : False
    PendFileRename : False
    PendFileRenVal : 
    RebootPending : False

    Do you want to reboot a machine? (Y/N): Y
    Enter the computer name to reboot (or type 'ALL' to reboot all machines with pending reboots): Server01
    Rebooting Server01...

    This example checks the reboot status of Server01 and Server02 and provides an interactive prompt to reboot Server01.

.NOTES
    Author: TechBase IT
    Version: 3.0
    Updated: 2023-10-10
    Compatibility: PowerShell 5.1+, Windows Server 2008 R2+
#>

function Get-PendingReboot {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias("CN", "Computer")]
        [String[]]$ComputerName = $env:COMPUTERNAME,

        [String]$ErrorLog
    )

    begin {
        Write-Verbose "Starting Get-PendingReboot function."
    }

    process {
        $pendingRebootList = @()

        foreach ($Computer in $ComputerName) {
            try {
                Write-Verbose "Checking reboot status for computer: $Computer"

                # Initialize variables
                $CompPendRen, $PendFileRename, $Pending, $SCCM = $false, $false, $false, $false
                $CBSRebootPend = $null

                # Query WMI for OS build number and computer name
                $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop
                Write-Verbose "Connected to WMI on $Computer."

                # Connect to the registry
                $HKLM = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

                # Check Component-Based Servicing (CBS) for pending reboots (Windows 2008+)
                if ([Int32]$WMI_OS.BuildNumber -ge 6001) {
                    $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")
                    $CBSRebootPend = $RegSubKeysCBS.sNames -contains "RebootPending"
                    Write-Verbose "CBS Reboot Pending: $CBSRebootPend"
                }

                # Check Windows Update for pending reboots
                $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM, "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
                $WUAURebootReq = $RegWUAURebootReq.sNames -contains "RebootRequired"
                Write-Verbose "Windows Update Reboot Required: $WUAURebootReq"

                # Check PendingFileRenameOperations
                $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\Session Manager\", "PendingFileRenameOperations")
                $RegValuePFRO = $RegSubKeySM.sValue
                $PendFileRename = $RegValuePFRO -ne $null
                Write-Verbose "Pending File Rename Operations: $PendFileRename"

                # Check for pending computer rename or domain join
                $Netlogon = $WMI_Reg.EnumKey($HKLM, "SYSTEM\CurrentControlSet\Services\Netlogon").sNames
                $PendDomJoin = ($Netlogon -contains 'JoinDomain') -or ($Netlogon -contains 'AvoidSpnSet')
                $ActCompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\", "ComputerName")
                $CompNm = $WMI_Reg.GetStringValue($HKLM, "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\", "ComputerName")
                $CompPendRen = ($ActCompNm -ne $CompNm) -or $PendDomJoin
                Write-Verbose "Pending Computer Rename: $CompPendRen"

                # Check SCCM 2012 Client SDK for pending reboots
                $CCMClientSDK = $null
                try {
                    $CCMClientSDK = Invoke-WmiMethod -Namespace 'ROOT\ccm\ClientSDK' -Class 'CCM_ClientUtilities' -Name 'DetermineIfRebootPending' -ComputerName $Computer -ErrorAction Stop
                    if ($CCMClientSDK.ReturnValue -ne 0) {
                        Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"
                    }
                    $SCCM = $CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending
                } catch {
                    Write-Verbose "SCCM Client SDK not available or error encountered: $_"
                }
                Write-Verbose "SCCM Reboot Pending: $SCCM"

                # Create output object
                $rebootPending = $CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename
                $result = [PSCustomObject]@{
                    Computer            = $WMI_OS.CSName
                    CBServicing         = $CBSRebootPend
                    WindowsUpdate       = $WUAURebootReq
                    CCMClientSDK        = $SCCM
                    PendComputerRename  = $CompPendRen
                    PendFileRename      = $PendFileRename
                    PendFileRenVal      = $RegValuePFRO
                    RebootPending       = $rebootPending
                }

                $pendingRebootList += $result

                # Output the result
                $result

            } catch {
                Write-Warning "Error checking $Computer`: $_"
                if ($ErrorLog) {
                    "$Computer, $_" | Out-File -FilePath $ErrorLog -Append
                }
            }
        }

        # Interactive reboot prompt
        if ($pendingRebootList.RebootPending -contains $true) {
            $rebootChoice = Read-Host "Do you want to reboot a machine? (Y/N)"
            if ($rebootChoice -eq 'Y' -or $rebootChoice -eq 'y') {
                $rebootTarget = Read-Host "Enter the computer name to reboot (or type 'ALL' to reboot all machines with pending reboots)"
                if ($rebootTarget -eq 'ALL') {
                    foreach ($machine in $pendingRebootList) {
                        if ($machine.RebootPending) {
                            Write-Host "Rebooting $($machine.Computer)..."
                            Restart-Computer -ComputerName $machine.Computer -Force
                        }
                    }
                } else {
                    $targetMachine = $pendingRebootList | Where-Object { $_.Computer -eq $rebootTarget -and $_.RebootPending }
                    if ($targetMachine) {
                        Write-Host "Rebooting $($targetMachine.Computer)..."
                        Restart-Computer -ComputerName $targetMachine.Computer -Force
                    } else {
                        Write-Host "No pending reboot found for $rebootTarget or the machine does not require a reboot."
                    }
                }
            }
        } else {
            Write-Host "No machines with pending reboots found."
        }
    }

    end {
        Write-Verbose "Get-PendingReboot function completed."
    }
}