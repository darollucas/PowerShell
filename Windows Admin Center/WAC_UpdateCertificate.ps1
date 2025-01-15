<#
.SYNOPSIS
Automates the process of updating the SSL certificate for Windows Admin Center (WAC).

.DESCRIPTION
This script automates the manual steps required to update the SSL certificate for WAC:
1. Stops the WAC service.
2. Retrieves the current SSL certificate binding.
3. Deletes the existing binding.
4. Selects the new certificate based on its Subject (e.g., CN=wac.techbaseit.com).
5. Binds the new certificate.
6. Restarts the WAC service.

.NOTES
Author: TechBase IT
Date: 2023-10-05
Version: 1.1

.EXAMPLE
PS> .\Update-WACCertificate.ps1
Automatically updates the SSL certificate binding for WAC.
#>

# Define the certificate subject to look for
$certificateSubject = "CN=wac.techbaseit.com"

# Stop the Windows Admin Center service
Write-Output "[*] Stopping Windows Admin Center services..."
try {
    Get-Service ServerManagementGateway* | Stop-Service -Force
    Write-Output "[+] Services stopped successfully."
} catch {
    Write-Error "Failed to stop WAC services: $_"
    exit 1
}

# Retrieve the current SSL certificate binding
Write-Output "[*] Retrieving the current SSL certificate binding..."
try {
    $sslCertInfo = netsh http show sslcert ipport=0.0.0.0:443
    $appID = ($sslCertInfo | Select-String -Pattern "Application ID" -Context 0,1 | Out-String).Split(":")[1].Trim()
    Write-Output "[+] Current Application ID: $appID"
} catch {
    Write-Error "Failed to retrieve SSL certificate binding: $_"
    exit 1
}

# Delete the existing SSL certificate binding
Write-Output "[*] Deleting the current SSL certificate binding..."
try {
    netsh http delete sslcert ipport=0.0.0.0:443
    Write-Output "[+] SSL certificate binding deleted successfully."
} catch {
    Write-Error "Failed to delete SSL certificate binding: $_"
    exit 1
}

# Retrieve the new certificate based on its subject
Write-Output "[*] Retrieving the new certificate with subject: $certificateSubject..."
try {
    $newCertificate = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -eq $certificateSubject }
    if (-not $newCertificate) {
        Write-Error "No certificate found with subject: $certificateSubject."
        exit 1
    }

    $newThumbprint = $newCertificate.Thumbprint
    Write-Output "[+] Selected certificate thumbprint: $newThumbprint"
} catch {
    Write-Error "Failed to retrieve the new certificate: $_"
    exit 1
}

# Bind the new SSL certificate
Write-Output "[*] Binding the new SSL certificate..."
try {
    netsh http add sslcert ipport=0.0.0.0:443 certhash=$newThumbprint appid=$appID
    Write-Output "[+] SSL certificate binding updated successfully."
} catch {
    Write-Error "Failed to bind the new SSL certificate: $_"
    exit 1
}

# Restart the Windows Admin Center service
Write-Output "[*] Restarting Windows Admin Center services..."
try {
    Get-Service ServerManagementGateway* | Start-Service
    Write-Output "[+] Services restarted successfully."
} catch {
    Write-Error "Failed to restart WAC services: $_"
    exit 1
}

Write-Output "[*] Script completed successfully."