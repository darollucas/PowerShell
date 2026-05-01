<#
.SYNOPSIS
    Bootstraps WinRM on remote Windows machines that have WinRM stopped or
    disabled, enabling Windows Admin Center and PowerShell remoting connectivity.

.DESCRIPTION
    This script targets domain-joined Windows machines where WinRM is not yet
    running and cannot be reached via Invoke-Command. It uses sc.exe to start
    the WinRM service remotely over SMB (which does not require WinRM), then
    uses Invoke-Command to set WinRM to Automatic startup, enable the correct
    firewall rule on the Domain profile, and force a Group Policy refresh.

    The script accepts machine names interactively or from a text file, tests
    reachability before attempting bootstrap, reports per-machine results, and
    logs all output to a user-specified log file.

    Intended to be run once after deploying a WinRM Group Policy Object to an
    OU. The GPO maintains the state going forward. This script handles the
    initial bootstrap on machines where WinRM is too disabled to receive the
    GPO on its own.

.COMPATIBILITY
    PowerShell 5.1 or newer required.
    Must be run as a Domain Administrator or equivalent.
    Requires SMB (port 445) access to target machines.
    Compatible with Windows 10, Windows 11, and Windows Server 2016 and newer.
    Run from a domain-joined machine with the Active Directory RSAT module
    installed if using the OU-based input method.

.NOTES
    Script Name : Enable-WinRMBootstrap.ps1
    Created By  : TechBase IT
    Version     : 1.0

.EXAMPLE
    # Interactive mode - script prompts for all inputs
    .\Enable-WinRMBootstrap.ps1

.EXAMPLE
    # Verbose output to see every step in real time
    .\Enable-WinRMBootstrap.ps1 -Verbose

.EXAMPLE
    # Dry run to see what would happen without making changes
    .\Enable-WinRMBootstrap.ps1 -WhatIf
#>

[CmdletBinding(SupportsShouldProcess)]
param ()

# -----------------------------------------------------------------------
# LOGGING FUNCTION
# -----------------------------------------------------------------------
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    $line      = "$timestamp [$Level] $Message"

    switch ($Level) {
        "ERROR"   { Write-Host $line -ForegroundColor Red }
        "WARN"    { Write-Host $line -ForegroundColor Yellow }
        "OK"      { Write-Host $line -ForegroundColor Green }
        "SKIP"    { Write-Host $line -ForegroundColor DarkGray }
        default   { Write-Host $line }
    }

    Write-Verbose $line
    Add-Content -Path $script:LogPath -Value $line -ErrorAction SilentlyContinue
}

# -----------------------------------------------------------------------
# BANNER
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  TechBase IT -- WinRM Bootstrap Script v1.0" -ForegroundColor Cyan
Write-Host "  Host: $($env:COMPUTERNAME)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# -----------------------------------------------------------------------
# INTERACTIVE INPUT COLLECTION
# -----------------------------------------------------------------------

# Log path
$defaultLog = "C:\Temp\WinRM-Bootstrap.log"
$logInput   = Read-Host "Log file path [press Enter to use $defaultLog]"
$script:LogPath = if ($logInput -ne "") { $logInput } else { $defaultLog }

$logDir = Split-Path $script:LogPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Write-Log "================================================================"
Write-Log "TechBase IT -- WinRM Bootstrap Script v1.0"
Write-Log "Executed by : $($env:USERDOMAIN)\$($env:USERNAME)"
Write-Log "From host   : $($env:COMPUTERNAME)"
Write-Log "================================================================"

# Input method
Write-Host ""
Write-Host "How do you want to provide the target machine list?" -ForegroundColor Yellow
Write-Host "  [1] Type machine names manually"
Write-Host "  [2] Load from a text file (one hostname per line)"
Write-Host "  [3] Pull from an Active Directory OU"
Write-Host ""
$inputMethod = Read-Host "Select an option [1, 2, or 3]"

$targets = @()

switch ($inputMethod) {
    "1" {
        Write-Host ""
        Write-Host "Enter machine names one at a time. Press Enter with no input when done." -ForegroundColor Yellow
        while ($true) {
            $entry = Read-Host "Machine name (or press Enter to finish)"
            if ($entry -eq "") { break }
            $targets += $entry.Trim()
        }
    }
    "2" {
        Write-Host ""
        $filePath = Read-Host "Full path to text file containing machine names"
        if (-not (Test-Path $filePath)) {
            Write-Log "File not found: $filePath" "ERROR"
            exit 1
        }
        $targets = Get-Content $filePath | Where-Object { $_.Trim() -ne "" } | ForEach-Object { $_.Trim() }
        Write-Log "Loaded $($targets.Count) machine(s) from $filePath"
    }
    "3" {
        Write-Host ""
        $ouDN = Read-Host "Enter the full OU Distinguished Name (e.g. OU=Workstations,OU=IT,DC=contoso,DC=com)"
        Write-Verbose "Querying AD for computers in: $ouDN"
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
            $targets = Get-ADComputer -Filter * -SearchBase $ouDN |
                Select-Object -ExpandProperty DNSHostName
            Write-Log "Found $($targets.Count) machine(s) in OU: $ouDN"
        } catch {
            Write-Log "Failed to query Active Directory: $_" "ERROR"
            exit 1
        }
    }
    default {
        Write-Log "Invalid selection. Exiting." "ERROR"
        exit 1
    }
}

if ($targets.Count -eq 0) {
    Write-Log "No target machines provided. Exiting." "ERROR"
    exit 1
}

Write-Log "Target machine count: $($targets.Count)"

# WinRM firewall rule name
Write-Host ""
$defaultRule = "WINRM-HTTP-In-TCP-NoScope"
$ruleInput   = Read-Host "WinRM firewall rule name [press Enter to use $defaultRule]"
$FirewallRule = if ($ruleInput -ne "") { $ruleInput } else { $defaultRule }
Write-Verbose "Firewall rule: $FirewallRule"
Write-Log "Firewall rule: $FirewallRule"

# SC.exe wait time
Write-Host ""
$waitInput = Read-Host "Seconds to wait after starting WinRM before connecting [press Enter to use 5]"
$WaitSeconds = if ($waitInput -ne "") { [int]$waitInput } else { 5 }
Write-Verbose "Wait time after sc.exe start: $WaitSeconds seconds"

# -----------------------------------------------------------------------
# PRE-FLIGHT: TEST REACHABILITY
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "================================================================"
Write-Log "PRE-FLIGHT: Testing reachability on all targets..."
Write-Log "================================================================"

$reachable   = @()
$unreachable = @()
$alreadyDone = @()

foreach ($machine in $targets) {
    Write-Verbose "Testing connectivity to $machine"
    $ping = Test-NetConnection -ComputerName $machine -Port 5985 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

    if (-not $ping.PingSucceeded) {
        Write-Log "[$machine] UNREACHABLE - offline or DNS not resolving. Skipping." "SKIP"
        $unreachable += $machine
    } elseif ($ping.TcpTestSucceeded) {
        Write-Log "[$machine] WinRM already reachable on port 5985. Skipping bootstrap." "OK"
        $alreadyDone += $machine
    } else {
        Write-Log "[$machine] Reachable via ping but WinRM not running. Queued for bootstrap."
        $reachable += $machine
    }
}

Write-Log "Pre-flight complete."
Write-Log "  Already working : $($alreadyDone.Count)"
Write-Log "  Needs bootstrap : $($reachable.Count)"
Write-Log "  Unreachable     : $($unreachable.Count)"

if ($reachable.Count -eq 0) {
    Write-Log "No machines require bootstrapping. Exiting." "OK"
    exit 0
}

# -----------------------------------------------------------------------
# BOOTSTRAP
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "================================================================"
Write-Log "BOOTSTRAP: Starting WinRM on $($reachable.Count) machine(s)..."
Write-Log "================================================================"

$results = @()

foreach ($machine in $reachable) {
    Write-Host ""
    Write-Log "[$machine] Starting bootstrap..."

    # Step 1: Start WinRM via sc.exe over SMB
    Write-Log "[$machine] Starting WinRM service via sc.exe..."
    Write-Verbose "Running: sc.exe \\$machine start WinRM"

    if ($PSCmdlet.ShouldProcess($machine, "Start WinRM service via sc.exe")) {
        $scOutput = & sc.exe \\$machine start WinRM 2>&1
        Write-Verbose "[$machine] sc.exe output: $scOutput"

        if ($scOutput -match "FAILED|Access is denied|could not be found") {
            Write-Log "[$machine] sc.exe failed: $scOutput" "ERROR"
            $results += [PSCustomObject]@{
                ComputerName = $machine
                Status       = "FAILED - sc.exe error"
                Detail       = $scOutput
            }
            continue
        }

        Write-Log "[$machine] WinRM service start requested. Waiting $WaitSeconds seconds..."
        Start-Sleep -Seconds $WaitSeconds
    }

    # Step 2: Connect via Invoke-Command and configure
    Write-Log "[$machine] Connecting via WinRM to configure service and firewall..."
    Write-Verbose "[$machine] Running Invoke-Command configuration block"

    if ($PSCmdlet.ShouldProcess($machine, "Configure WinRM service and firewall via Invoke-Command")) {
        try {
            $remoteResult = Invoke-Command -ComputerName $machine -ErrorAction Stop -ScriptBlock {
                param($RuleName)

                # Set WinRM to Automatic
                Set-Service WinRM -StartupType Automatic

                # Enable the Domain profile firewall rule
                Enable-NetFirewallRule -Name $RuleName -ErrorAction SilentlyContinue

                # Force GPO refresh
                $gpResult = gpupdate /force 2>&1

                # Return status
                [PSCustomObject]@{
                    ComputerName  = $env:COMPUTERNAME
                    WinRMStatus   = (Get-Service WinRM).Status.ToString()
                    WinRMStartup  = (Get-Service WinRM).StartType.ToString()
                    FirewallRule  = (Get-NetFirewallRule -Name $RuleName -ErrorAction SilentlyContinue).Enabled
                    GPUpdateDone  = $true
                }
            } -ArgumentList $FirewallRule

            Write-Log "[$machine] Bootstrap complete." "OK"
            Write-Verbose "[$machine] WinRM Status: $($remoteResult.WinRMStatus) | Startup: $($remoteResult.WinRMStartup) | Firewall: $($remoteResult.FirewallRule)"

            $results += [PSCustomObject]@{
                ComputerName = $machine
                Status       = "SUCCESS"
                WinRM        = $remoteResult.WinRMStatus
                Startup      = $remoteResult.WinRMStartup
                Firewall     = $remoteResult.FirewallRule
            }
        } catch {
            Write-Log "[$machine] Invoke-Command failed: $_" "ERROR"
            $results += [PSCustomObject]@{
                ComputerName = $machine
                Status       = "FAILED - Invoke-Command error"
                WinRM        = "Unknown"
                Startup      = "Unknown"
                Firewall     = "Unknown"
            }
        }
    }
}

# -----------------------------------------------------------------------
# POST-VERIFICATION
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "================================================================"
Write-Log "POST-VERIFICATION: Re-testing port 5985 on bootstrapped machines..."
Write-Log "================================================================"

foreach ($result in $results | Where-Object { $_.Status -eq "SUCCESS" }) {
    $verify = Test-NetConnection -ComputerName $result.ComputerName -Port 5985 -WarningAction SilentlyContinue
    if ($verify.TcpTestSucceeded) {
        Write-Log "[$($result.ComputerName)] Port 5985 confirmed open." "OK"
        $result.Status = "VERIFIED"
    } else {
        Write-Log "[$($result.ComputerName)] Port 5985 still closed after bootstrap." "WARN"
        $result.Status = "UNVERIFIED - port still closed"
    }
}

# -----------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Log "SUMMARY"
Write-Host "================================================================" -ForegroundColor Cyan
Write-Log "  Already working before script : $($alreadyDone.Count)"
Write-Log "  Successfully bootstrapped     : $(($results | Where-Object { $_.Status -eq 'VERIFIED' }).Count)"
Write-Log "  Bootstrap attempted, unverified: $(($results | Where-Object { $_.Status -like 'UNVERIFIED*' }).Count)"
Write-Log "  Failed                        : $(($results | Where-Object { $_.Status -like 'FAILED*' }).Count)"
Write-Log "  Unreachable / skipped         : $($unreachable.Count)"
Write-Log "  Log file                      : $script:LogPath"
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Per-machine results:" -ForegroundColor Yellow
$results | Format-Table ComputerName, Status, WinRM, Startup, Firewall -AutoSize

if ($unreachable.Count -gt 0) {
    Write-Host ""
    Write-Host "Skipped (unreachable):" -ForegroundColor DarkGray
    $unreachable | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
}

if ($alreadyDone.Count -gt 0) {
    Write-Host ""
    Write-Host "Already working (no action taken):" -ForegroundColor Green
    $alreadyDone | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
}