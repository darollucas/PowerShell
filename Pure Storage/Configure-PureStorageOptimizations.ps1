<#
.SYNOPSIS
Configures a Windows Server host for optimal connection with Pure Storage arrays according to 2024 best practices.

.DESCRIPTION
This PowerShell script optimizes Windows Server settings for Pure Storage by configuring Multipath I/O (MPIO) settings and adjusting system configurations as recommended in the 2024 Pure Storage best practices. It ensures that the server is properly set up to communicate with Pure Storage FlashArray devices.

.EXAMPLE
PS> .\Configure-PureStorageOptimizations.ps1

This command runs the script to configure the server based on Pure Storage best practices.

.NOTES
Author: TechBase IT
Date Created: 04/24/2024
Date Modified: 04/24/2024
Compatibility: PowerShell 5.1 and up
#>

# Ensure running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run PowerShell as an Administrator."
    Exit
}

# Install Multipath-IO feature and its management tools
Install-WindowsFeature Multipath-IO -IncludeManagementTools
Write-Host "Multipath-IO feature and its management tools have been installed." -ForegroundColor Green

# Add Pure Storage support in MPIO if not already present
If (!(Get-MSDSMSupportedHW | Where-Object {$_.VendorId -eq 'PURE' -and $_.ProductId -eq 'FlashArray'})) {
    New-MSDSMSupportedHw -VendorId PURE -ProductId FlashArray
    Write-Host "Pure Storage support added to MPIO." -ForegroundColor Green
} Else {
    Write-Host "Pure Storage already supported by MPIO." -ForegroundColor Green
}

# Remove outdated vendor/product configurations from MPIO
Remove-MSDSMSupportedHw -VendorId 'Vendor*' -ProductId 'Product*'
Write-Host "Outdated vendor/product configurations removed from MPIO." -ForegroundColor Green

# Adjust MPIO settings as per best practices
Set-MPIOSetting -NewPathRecoveryInterval 20 -CustomPathRecovery Enabled -NewPDORemovePeriod 30 -NewDiskTimeout 60 -NewPathVerificationState Enabled
Write-Host "MPIO settings have been adjusted according to Pure Storage best practices." -ForegroundColor Green

# Additional configurations and checks can be added below as needed.