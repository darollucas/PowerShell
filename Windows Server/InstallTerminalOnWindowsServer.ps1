<#
.SYNOPSIS
Download and install the newest version of Windows Terminal Application.

.DESCRIPTION
This PowerShell script allows you to download and install the latest version of Windows Terminal Application from the specified URL. It automatically handles prerequisites installation and performs the download and installation tasks using BitsTransfer and Add-AppxPackage cmdlets.

.NOTES
- Make sure you have an active internet connection to download the Windows Terminal Application.
- The script will automatically download and install the necessary prerequisites before installing the Windows Terminal Application.

#>

# Provide URL to newest version of Windows Terminal Application
$url = 'https://github.com/microsoft/terminal/releases/download/v1.16.10261.0/Microsoft.WindowsTerminal_Win10_1.16.10261.0_8wekyb3d8bbwe.msixbundle'
$split = Split-Path $url -Leaf

# Prerequisites
Write-Host "Downloading and installing Microsoft VCLibs x86 14.00 Desktop..."
Start-BitsTransfer -Source 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' `
    -Destination $home\Microsoft.VCLibs.x86.14.00.Desktop.appx
Add-AppxPackage $home\Microsoft.VCLibs.x86.14.00.Desktop.appx

# Download
Write-Host "Downloading Windows Terminal..."
Start-BitsTransfer -Source $url `
    -Destination (Join-Path -Path $home -ChildPath $split)

# Installation
Write-Host "Installing Windows Terminal..."
Add-AppxPackage -Path (Join-Path -Path $home -ChildPath $split)

Write-Host "Windows Terminal installation completed successfully!"