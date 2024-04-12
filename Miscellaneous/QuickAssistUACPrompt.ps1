# PowerShell Script to Toggle UAC Prompt on Secure Desktop for Quick Assist

function Toggle-UACPromptOnSecureDesktop {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Enable","Disable")]
        [string]$Action
    )

    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $name = "PromptOnSecureDesktop"
    $value = if ($Action -eq "Disable") { 0 } else { 1 }

    try {
        # Check if the registry path exists
        if (-not (Test-Path $registryPath)) {
            Write-Error "Registry path does not exist."
            return
        }

        # Update the registry value
        Set-ItemProperty -Path $registryPath -Name $name -Value $value
        Write-Host "UAC prompt on secure desktop has been set to: $Action" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update the registry. Error: $_"
    }
}

# Main script
Write-Host "This script toggles the UAC prompt on secure desktop setting for Quick Assist on Windows 11."
$action = Read-Host "Enter 'Enable' to enable UAC prompt on secure desktop or 'Disable' to disable it"
Toggle-UACPromptOnSecureDesktop -Action $action

Write-Host "Remember, if you disabled the UAC prompt on secure desktop, be sure to enable it back after your Quick Assist session for security reasons." -ForegroundColor Yellow