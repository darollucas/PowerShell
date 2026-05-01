<#
.SYNOPSIS
    Configures or updates the SSL certificate for Windows Admin Center (v2)
    using a certificate issued by CertifyTheWeb via Let's Encrypt.

.DESCRIPTION
    This script handles the full certificate binding process for Windows Admin
    Center (WAC) v2, which manages its own certificate configuration internally
    and cannot be updated via netsh alone.

    The script performs the following:
      1. Prompts the user for all required inputs interactively
      2. Locates the target certificate in the local machine store
      3. Ensures the Let's Encrypt R12 intermediate is installed
      4. Verifies the certificate is not already active (no-op if current)
      5. Grants Network Service access to the certificate private key
      6. Reconfigures WAC via its installer to bind the new certificate
      7. Waits for WAC services to return to Running state
      8. Verifies the correct certificate is being served post-update
      9. Logs all activity to a user-specified log path

    Designed to work as a standalone run or as a CertifyTheWeb post-renewal
    deployment task. When used with CertifyTheWeb, pass the thumbprint via
    the -Thumbprint parameter to skip interactive selection.

.COMPATIBILITY
    PowerShell 5.1 or newer required.
    Compatible with Windows Server 2016, 2019, 2022, and 2025.
    Must be run as a local Administrator on the WAC gateway server.
    Requires outbound HTTPS access to letsencrypt.org if the R12 intermediate
    is not already installed.

.NOTES
    Script Name : Update-WACCertificate.ps1
    Created By  : TechBase IT
    Version     : 3.1

.EXAMPLE
    # Interactive mode - script prompts for all inputs
    .\Update-WACCertificate.ps1

.EXAMPLE
    # CertifyTheWeb deployment hook - thumbprint passed automatically
    .\Update-WACCertificate.ps1 -Thumbprint "{thumbprint}"

.EXAMPLE
    # Dry run to validate without making changes
    .\Update-WACCertificate.ps1 -WhatIf

.EXAMPLE
    # Verbose output to see every step in real time
    .\Update-WACCertificate.ps1 -Verbose
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [string]$Thumbprint = ""
)

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
        "ERROR" { Write-Host $line -ForegroundColor Red }
        "WARN"  { Write-Host $line -ForegroundColor Yellow }
        "OK"    { Write-Host $line -ForegroundColor Green }
        default { Write-Host $line }
    }

    Write-Verbose $line
    Add-Content -Path $script:LogPath -Value $line -ErrorAction SilentlyContinue
}

function Exit-Script {
    param([int]$Code, [string]$Message)
    if ($Code -ne 0) {
        Write-Log $Message "ERROR"
    } else {
        Write-Log $Message "OK"
    }
    exit $Code
}

# -----------------------------------------------------------------------
# BANNER
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  TechBase IT -- WAC Certificate Update Script v3.1" -ForegroundColor Cyan
Write-Host "  Host: $($env:COMPUTERNAME)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# -----------------------------------------------------------------------
# INTERACTIVE INPUT COLLECTION
# -----------------------------------------------------------------------

# Log path
$defaultLog = "C:\ProgramData\WindowsAdminCenter\Logs\CertUpdate.log"
$logInput   = Read-Host "Log file path [press Enter to use $defaultLog]"
$script:LogPath = if ($logInput -ne "") { $logInput } else { $defaultLog }

# Ensure log directory exists
$logDir = Split-Path $script:LogPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Write-Log "================================================================"
Write-Log "TechBase IT -- WAC Certificate Update Script v3.1"
Write-Log "Host: $($env:COMPUTERNAME)"
Write-Log "================================================================"

# WAC installer path
Write-Host ""
$InstallerPath = Read-Host "Full path to the WAC installer EXE (e.g. C:\Tools\WindowsAdminCenter2410.exe)"
Write-Verbose "Installer path provided: $InstallerPath"

if (-not (Test-Path $InstallerPath)) {
    Exit-Script 1 "Installer not found at '$InstallerPath'. Verify the path and try again."
}
Write-Log "Installer: $InstallerPath [FOUND]" "OK"

# WAC port
Write-Host ""
$portInput = Read-Host "WAC HTTPS port [press Enter to use 443]"
$Port      = if ($portInput -ne "") { [int]$portInput } else { 443 }
Write-Verbose "WAC port set to: $Port"
Write-Log "Port: $Port"

# Certificate subject
Write-Host ""
$subjectInput        = Read-Host "Certificate subject name [press Enter to use CN=wac.techbaseit.com]"
$CertificateSubject  = if ($subjectInput -ne "") { $subjectInput } else { "CN=wac.techbaseit.com" }
Write-Verbose "Certificate subject: $CertificateSubject"
Write-Log "Certificate subject: $CertificateSubject"

# R12 intermediate download temp path
Write-Host ""
$tempInput = Read-Host "Temp folder for intermediate cert download [press Enter to use C:\Temp]"
$TempPath  = if ($tempInput -ne "") { $tempInput } else { "C:\Temp" }
$R12_DEST  = Join-Path $TempPath "r12.der"
Write-Verbose "Temp path: $TempPath"

# -----------------------------------------------------------------------
# STEP 1: Locate target certificate
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "STEP 1: Locating target certificate..."

if ($Thumbprint -ne "") {
    Write-Verbose "Thumbprint provided directly: $Thumbprint"
    Write-Log "Thumbprint provided via parameter. Skipping interactive selection."

    $targetCert = Get-ChildItem Cert:\LocalMachine\My |
        Where-Object {
            $_.Thumbprint -eq $Thumbprint -and
            $_.NotAfter   -gt (Get-Date) -and
            $_.NotBefore  -le (Get-Date)
        }

    if (-not $targetCert) {
        Exit-Script 1 "No valid certificate found with thumbprint '$Thumbprint'. Verify CertifyTheWeb installed the cert to LocalMachine\My."
    }
} else {
    Write-Verbose "No thumbprint provided. Searching store for newest valid Let's Encrypt cert matching subject."

    $matchingCerts = Get-ChildItem Cert:\LocalMachine\My |
        Where-Object {
            $_.Subject   -eq $CertificateSubject -and
            $_.Issuer    -like "*Let's Encrypt*" -and
            $_.NotAfter  -gt (Get-Date) -and
            $_.NotBefore -le (Get-Date)
        } |
        Sort-Object NotAfter -Descending

    if (-not $matchingCerts) {
        Exit-Script 1 "No valid Let's Encrypt certificate found with subject '$CertificateSubject'. Verify CertifyTheWeb has issued and installed the certificate to LocalMachine\My."
    }

    # If multiple valid certs exist, show them and let the user choose
    if ($matchingCerts.Count -gt 1) {
        Write-Host ""
        Write-Host "Multiple valid certificates found. Select one:" -ForegroundColor Yellow
        $index = 0
        foreach ($cert in $matchingCerts) {
            Write-Host "  [$index] Thumbprint: $($cert.Thumbprint)  Expires: $($cert.NotAfter)"
            $index++
        }
        Write-Host ""
        $selection  = Read-Host "Enter the number of the certificate to use [press Enter for 0 - newest]"
        $selection  = if ($selection -ne "") { [int]$selection } else { 0 }
        $targetCert = $matchingCerts[$selection]
    } else {
        $targetCert = $matchingCerts | Select-Object -First 1
    }
}

$newThumbprint = $targetCert.Thumbprint
Write-Log "Certificate selected:" "OK"
Write-Log "  Subject    : $($targetCert.Subject)"
Write-Log "  Issuer     : $($targetCert.Issuer)"
Write-Log "  Thumbprint : $newThumbprint"
Write-Log "  Expires    : $($targetCert.NotAfter)"

# -----------------------------------------------------------------------
# STEP 2: Check if this cert is already active
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "STEP 2: Checking currently active WAC certificate..."
Write-Verbose "Opening TLS connection to localhost:$Port to read active certificate."

try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient("localhost", $Port)
    $sslStream = New-Object System.Net.Security.SslStream(
        $tcpClient.GetStream(), $false, { $true }
    )
    $sslStream.AuthenticateAsClient("localhost")
    $activeCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
        $sslStream.RemoteCertificate
    )
    $currentThumbprint = $activeCert.Thumbprint
    $sslStream.Close()
    $tcpClient.Close()

    Write-Log "Currently active thumbprint: $currentThumbprint"
    Write-Verbose "Active thumbprint: $currentThumbprint | Target thumbprint: $newThumbprint"

    if ($currentThumbprint -eq $newThumbprint) {
        Exit-Script 0 "Target certificate is already active on port $Port. Nothing to do."
    }

    Write-Log "Active certificate differs from target. Proceeding with update." "WARN"
} catch {
    Write-Log "Could not read active certificate -- WAC may be stopped or using self-signed. Proceeding." "WARN"
    Write-Verbose "TLS check error: $_"
    $currentThumbprint = $null
}

# -----------------------------------------------------------------------
# STEP 3: Ensure Let's Encrypt R12 intermediate is installed
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "STEP 3: Checking for Let's Encrypt R12 intermediate certificate..."
Write-Verbose "Searching Cert:\LocalMachine\CA for R12 intermediate."

$r12Installed = Get-ChildItem Cert:\LocalMachine\CA |
    Where-Object {
        $_.Subject -like "*CN=R12*" -and
        $_.Subject -like "*Let's Encrypt*"
    }

if ($r12Installed) {
    Write-Log "R12 intermediate already installed. [OK]" "OK"
    Write-Verbose "R12 thumbprint in store: $($r12Installed.Thumbprint)"
} else {
    Write-Log "R12 intermediate not found. Downloading and installing..." "WARN"

    if ($PSCmdlet.ShouldProcess("Cert:\LocalMachine\CA", "Install Let's Encrypt R12 intermediate")) {
        try {
            if (-not (Test-Path $TempPath)) {
                New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
                Write-Verbose "Created temp directory: $TempPath"
            }

            Write-Verbose "Downloading R12 from: https://letsencrypt.org/certs/2024/r12.der"
            Invoke-WebRequest -Uri "https://letsencrypt.org/certs/2024/r12.der" -OutFile $R12_DEST -ErrorAction Stop

            Write-Verbose "Importing R12 into Cert:\LocalMachine\CA"
            Import-Certificate -FilePath $R12_DEST -CertStoreLocation Cert:\LocalMachine\CA -ErrorAction Stop | Out-Null

            Remove-Item $R12_DEST -Force -ErrorAction SilentlyContinue
            Write-Log "R12 intermediate installed successfully." "OK"
        } catch {
            Exit-Script 1 "Failed to install R12 intermediate: $_"
        }
    }
}

# -----------------------------------------------------------------------
# STEP 4: Grant Network Service access to private key
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "STEP 4: Verifying Network Service access to certificate private key..."

try {
    $rsaKey  = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($targetCert)
    $keyName = $rsaKey.Key.UniqueName
    Write-Verbose "Private key unique name: $keyName"

    $keyPath = "$env:ProgramData\Microsoft\Crypto\Keys\$keyName"
    if (-not (Test-Path $keyPath)) {
        $keyPath = (Get-ChildItem "$env:ProgramData\Microsoft\Crypto\RSA\MachineKeys" |
            Where-Object { $_.Name -like "*$keyName*" } |
            Select-Object -First 1 -ExpandProperty FullName)
    }

    if ($keyPath -and (Test-Path $keyPath)) {
        Write-Verbose "Private key file: $keyPath"
        $acl         = Get-Acl $keyPath
        $nsHasAccess = $acl.Access | Where-Object {
            $_.IdentityReference -like "*NETWORK SERVICE*" -and
            $_.FileSystemRights  -match "Read|FullControl"
        }

        if (-not $nsHasAccess) {
            Write-Log "Network Service does not have access. Granting read permission..." "WARN"
            if ($PSCmdlet.ShouldProcess($keyPath, "Grant Network Service read access")) {
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    "NT AUTHORITY\NETWORK SERVICE", "Read", "Allow"
                )
                $acl.AddAccessRule($rule)
                Set-Acl $keyPath $acl
                Write-Log "Network Service access granted." "OK"
            }
        } else {
            Write-Log "Network Service already has private key access. [OK]" "OK"
        }
    } else {
        Write-Log "Private key file not found. Skipping ACL check." "WARN"
    }
} catch {
    Write-Log "Could not verify private key permissions: $_. Continuing." "WARN"
    Write-Verbose "Private key ACL error: $_"
}

# -----------------------------------------------------------------------
# STEP 5: Reconfigure WAC via installer
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "STEP 5: Reconfiguring WAC via installer..."
Write-Log "WAC services will stop, reconfigure, and restart automatically."
Write-Verbose "Installer: $InstallerPath"
Write-Verbose "Arguments: SME_PORT=$Port SME_THUMBPRINT=$newThumbprint SSL_CERTIFICATE_OPTION=installed"

if ($PSCmdlet.ShouldProcess($InstallerPath, "Reconfigure WAC with thumbprint $newThumbprint")) {
    try {
        $argList = "SME_PORT=$Port SME_THUMBPRINT=$newThumbprint SSL_CERTIFICATE_OPTION=installed"
        $process = Start-Process -FilePath $InstallerPath `
            -ArgumentList $argList `
            -Wait `
            -PassThru

        Write-Verbose "Installer exit code: $($process.ExitCode)"

        if ($process.ExitCode -ne 0) {
            Exit-Script 1 "WAC installer exited with code $($process.ExitCode). Check C:\ProgramData\WindowsAdminCenter\Logs\ for details."
        }

        Write-Log "WAC installer completed successfully." "OK"
    } catch {
        Exit-Script 1 "Failed to run WAC installer: $_"
    }
}

# -----------------------------------------------------------------------
# STEP 6: Wait for WAC service to reach Running state
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "STEP 6: Waiting for WAC services to reach Running state..."

$timeout  = 60
$elapsed  = 0
$interval = 5

do {
    Start-Sleep -Seconds $interval
    $elapsed += $interval

    $svc = Get-Service -Name "WindowsAdminCenter" -ErrorAction SilentlyContinue
    Write-Verbose "Service status at $elapsed seconds: $($svc.Status)"

    if ($svc.Status -eq "Running") {
        Write-Log "WAC service is Running." "OK"
        break
    }

    Write-Log "Waiting for WAC service... ($elapsed / $timeout seconds)"
} while ($elapsed -lt $timeout)

if ($svc.Status -ne "Running") {
    Exit-Script 1 "WAC service did not reach Running state within $timeout seconds. Check event logs."
}

# -----------------------------------------------------------------------
# STEP 7: Verify correct certificate is being served
# -----------------------------------------------------------------------
Write-Host ""
Write-Log "STEP 7: Verifying certificate being served by WAC..."
Start-Sleep -Seconds 5

try {
    Write-Verbose "Opening TLS connection to localhost:$Port for post-update verification."
    $tcpClient = New-Object System.Net.Sockets.TcpClient("localhost", $Port)
    $sslStream = New-Object System.Net.Security.SslStream(
        $tcpClient.GetStream(), $false, { $true }
    )
    $sslStream.AuthenticateAsClient("localhost")
    $verifycert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
        $sslStream.RemoteCertificate
    )
    $verifiedThumbprint = $verifycert.Thumbprint
    $sslStream.Close()
    $tcpClient.Close()

    Write-Verbose "Thumbprint served: $verifiedThumbprint"
    Write-Verbose "Thumbprint expected: $newThumbprint"

    if ($verifiedThumbprint -eq $newThumbprint) {
        Write-Log "Certificate verification PASSED. WAC is serving the correct certificate." "OK"
    } else {
        Write-Log "Certificate verification FAILED." "ERROR"
        Write-Log "  Served  : $verifiedThumbprint" "ERROR"
        Write-Log "  Expected: $newThumbprint" "ERROR"
        Exit-Script 1 "Certificate mismatch after update. Manual investigation required."
    }
} catch {
    Write-Log "Could not complete TLS verification: $_. Verify manually in browser." "WARN"
    Write-Verbose "TLS verification error: $_"
}

# -----------------------------------------------------------------------
# COMPLETION SUMMARY
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Log "WAC Certificate Update Complete"
Write-Log "  Host      : $($env:COMPUTERNAME)"
Write-Log "  Port      : $Port"
Write-Log "  Subject   : $($targetCert.Subject)"
Write-Log "  Issuer    : $($targetCert.Issuer)"
Write-Log "  Thumbprint: $newThumbprint"
Write-Log "  Expires   : $($targetCert.NotAfter)"
Write-Log "  Log       : $script:LogPath"
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""