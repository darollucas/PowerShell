#Define Cleanup function
function DoCleanup {
    Start-Process "$Env:SystemRoot\System32\cleanmgr.exe" -ArgumentList "/sagerun:1"
}

#Define function for setting Registry Keys
function SetRegKeys {
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"

    #Check if the path exists
    if (Test-Path $keyPath) {
        Get-ChildItem $keyPath | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "StateFlags0001" -Value 2
        }
    }
    else {
        Write-Host "Registry path $keyPath does not exist."
    }
}

# Call functions
SetRegKeys
DoCleanup