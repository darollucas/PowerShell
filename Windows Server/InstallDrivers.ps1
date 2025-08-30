#Requires -RunAsAdministrator

function Install-MissingDrivers {
    param(
        [string]$DriverPath = "C:\Drivers"
    )

    # Create log directory
    $logDir = "$env:SystemRoot\Temp\DriverLogs"
    if (!(Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }
    $logFile = "$logDir\DriverInstall_$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    
    # Start logging
    Start-Transcript -Path $logFile -Append

    Write-Host "=== Driver Installation Process Started ===" -ForegroundColor Green
    Write-Host "Scanning for unknown devices..." -ForegroundColor Yellow

    # Get all unknown devices (devices with error code 28)
    try {
        $unknownDevices = Get-WmiObject -Class Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -eq 28 }
    } catch {
        Write-Error "Failed to retrieve device information: $_"
        Stop-Transcript
        return
    }

    if (-not $unknownDevices) {
        Write-Host "No unknown devices found. All drivers are properly installed." -ForegroundColor Green
        Stop-Transcript
        return
    }

    Write-Host "Found $($unknownDevices.Count) unknown device(s)" -ForegroundColor Yellow

    # Verify driver repository exists
    if (-not (Test-Path $DriverPath)) {
        Write-Error "Driver repository path does not exist: $DriverPath"
        Stop-Transcript
        return
    }

    # Get all INF files recursively from driver repository
    $infFiles = Get-ChildItem -Path $DriverPath -Recurse -Filter "*.inf" -ErrorAction SilentlyContinue
    if (-not $infFiles) {
        Write-Error "No INF files found in driver repository: $DriverPath"
        Stop-Transcript
        return
    }

    Write-Host "Found $($infFiles.Count) driver files in repository" -ForegroundColor Yellow

    $successCount = 0
    $failCount = 0

    # Process each unknown device
    foreach ($device in $unknownDevices) {
        Write-Host "Processing device: $($device.Name)" -ForegroundColor Cyan
        Write-Host "Device ID: $($device.DeviceID)" -ForegroundColor Gray

        $hardwareIDs = $device.HardwareID
        if (-not $hardwareIDs) {
            Write-Host "No Hardware IDs found for this device" -ForegroundColor Red
            $failCount++
            continue
        }

        Write-Host "Hardware IDs: $($hardwareIDs -join ', ')" -ForegroundColor Gray

        $driverFound = $false
        # Check each hardware ID against all INF files
        foreach ($hwid in $hardwareIDs) {
            foreach ($infFile in $infFiles) {
                # Read INF file content
                $infContent = Get-Content $infFile.FullName -Raw -ErrorAction SilentlyContinue
                if (-not $infContent) {
                    continue
                }

                # Check if INF file contains the hardware ID (case-insensitive)
                if ($infContent -imatch [regex]::Escape($hwid)) {
                    Write-Host "Found matching driver: $($infFile.Name)" -ForegroundColor Green
                    
                    try {
                        # Install driver using PnPUtil
                        Write-Host "Installing driver..." -ForegroundColor Yellow
                        $result = pnputil.exe /add-driver $infFile.FullName /install 2>&1
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "Successfully installed driver for hardware ID: $hwid" -ForegroundColor Green
                            $driverFound = $true
                            $successCount++
                            break
                        } else {
                            Write-Host "Failed to install driver. Error: $result" -ForegroundColor Red
                            $failCount++
                        }
                    } catch {
                        Write-Host "Error installing driver: $_" -ForegroundColor Red
                        $failCount++
                    }
                    
                    # Break out of INF files loop if driver was found and installed
                    if ($driverFound) { break }
                }
            }
            # Break out of hardware IDs loop if driver was found and installed
            if ($driverFound) { break }
        }

        if (-not $driverFound) {
            Write-Host "No suitable driver found for this device" -ForegroundColor Red
            $failCount++
        }
        
        Write-Host "----------------------------------------" -ForegroundColor Gray
    }

    # Display summary
    Write-Host "=== Installation Summary ===" -ForegroundColor Cyan
    Write-Host "Successful installations: $successCount" -ForegroundColor Green
    Write-Host "Failed installations: $failCount" -ForegroundColor Red
    Write-Host "Total devices processed: $($unknownDevices.Count)" -ForegroundColor Yellow

    # Stop logging
    Stop-Transcript
    Write-Host "Log file created: $logFile" -ForegroundColor Cyan
}

# Interactive prompt for driver path
function Get-DriverPath {
    do {
        Clear-Host
        Write-Host "=== Driver Installation Script ===" -ForegroundColor Cyan
        Write-Host "This script will install drivers for unknown devices." -ForegroundColor White
        Write-Host ""
        
        $path = Read-Host "Please enter the path to your driver repository (or press Enter for default C:\Drivers)"
        if ([string]::IsNullOrEmpty($path)) {
            $path = "C:\Drivers"
        }
        
        if (-not (Test-Path $path)) {
            Write-Host "The path does not exist! Please try again." -ForegroundColor Red
            Write-Host ""
            Pause
        }
    } until (Test-Path $path)
    
    return $path
}

# Main execution
try {
    $driverPath = Get-DriverPath
    Install-MissingDrivers -DriverPath $driverPath
} catch {
    Write-Host "An unexpected error occurred: $_" -ForegroundColor Red
}

Write-Host "Script execution completed." -ForegroundColor Cyan
Pause