<#
.SYNOPSIS
    This script fetches and displays the creation date of virtual machines on a Hyper-V server.
.DESCRIPTION
    The script prompts the user for a Hyper-V host name, connects to that host, and retrieves information about each VM on that host. 
    The VM name and its creation date-time are displayed in a structured, human-readable format.
    The output format can be either console, text file, CSV, or HTML.
    System-created VMs, like "MicrosoftUEFICertificateAuthority" and "OpenSourceShieldedVM", are excluded.
    VMs with null creation times are also excluded.
#>

param([string]$hostName = (Read-Host "Please enter the Hyper-V host name"), 
    [string]$outputFormat = (Read-Host "Please enter the output format (console, txt, csv, html)"))

function WMIDateStringToDateTime( [String] $strWmiDate )
{
    $strWmiDate.Trim() > $null
    $iYear   = [Int32]::Parse($strWmiDate.SubString( 0, 4))
    $iMonth  = [Int32]::Parse($strWmiDate.SubString( 4, 2))
    $iDay    = [Int32]::Parse($strWmiDate.SubString( 6, 2))
    $iHour   = [Int32]::Parse($strWmiDate.SubString( 8, 2))
    $iMinute = [Int32]::Parse($strWmiDate.SubString(10, 2))
    $iSecond = [Int32]::Parse($strWmiDate.SubString(12, 2))
    $iMicroseconds = [Int32]::Parse($strWmiDate.Substring(15, 6))
    $iMilliseconds = $iMicroseconds / 1000
    $iUtcOffsetMinutes = [Int32]::Parse($strWmiDate.Substring(21, 4))
    
    if ( $iUtcOffsetMinutes -ne 0 )
    {
        $dtkind = [DateTimeKind]::Local
    }
    else
    {
        $dtkind = [DateTimeKind]::Utc
    }

    $dateObj = New-Object -TypeName DateTime `
                      -ArgumentList $iYear, $iMonth, $iDay, `
                                    $iHour, $iMinute, $iSecond, `
                                    $iMilliseconds, $dtkind
    return ($dateObj.ToString("MM/dd/yyyy hh:mm:ss tt"))
}

$VMinfo = @(get-wmiobject -computername $hostName -namespace root\virtualization\v2 Msvm_VirtualSystemSettingData)

$outputData = @()

foreach($x in $vminfo)
{
    # Exclude certain VMs and VMs with null creation time
    if($x.ElementName -notin @("MicrosoftUEFICertificateAuthority", "OpenSourceShieldedVM") -and $x.creationtime -ne $null)
    {
        $creationTime = WMIDateStringToDateTime -strWmiDate $x.creationtime 

        $outputData += New-Object PSObject -Property @{
            'VM Name' = $x.ElementName
            'Month' = (Get-Date $creationTime).Month
            'Day' = (Get-Date $creationTime).Day
            'Year' = (Get-Date $creationTime).Year
            'Time' = (Get-Date $creationTime).ToString("hh:mm:ss tt")
        } | Select 'VM Name','Month','Day','Year','Time'
    }
}

switch ($outputFormat) {
    "console" {
        $outputData | Format-Table
    }
    "txt" {
        $outputData | Format-Table | Out-File -FilePath .\output.txt
    }
    "csv" {
        $outputData | Export-Csv -Path .\output.csv -NoTypeInformation
    }
    "html" {
        $outputData | ConvertTo-Html -Title "Hyper-V VM Information" | Out-File -FilePath .\output.html
    }
    default {
        Write-Error "Invalid output format. Please specify one of the following: console, txt, csv, html."
    }
}
