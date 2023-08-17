<#
    Type : Powershell Script

    Description : This script will show missing Reverse Lookup DNS Zones
                  on a specified DNS server for a specific Forward Lookup
                  DNS zone.

    Version : 1.0

    Author : TechBase IT

    Date :  2023-08-15

    Keywords : DNS, Reverse, Zones, Active Directory

    MIT License: https://opensource.org/licenses/MIT

#>

# Prompt the user for DNS server and zone information
$DNSServerInput = Read-Host -Prompt "Enter DNS Server (e.g., server.contoso.com)"
$ZoneToCheck = Read-Host -Prompt "Enter DNS Zone to check (e.g., myzone.contoso.com)"
$OutputFile = "C:\Temp\Check-Missing-Reverse-Zones.txt"

$dnsEntries = @()
$dnsResult = @()
$MissingZones = @()
$RevResult = @()

# Explicitly cast user input to string type
$DNSServer = [string]$DNSServerInput

# Retrieve reverse lookup zones
$revZones = @(Get-DnsServerZone -ComputerName $DNSServer | Where-Object {$_.IsReverseLookupZone -EQ $true})

# Retrieve DNS entries for the specified forward lookup zone
$dnsEntries = Get-DnsServerResourceRecord -ComputerName $DNSServer -ZoneName $ZoneToCheck | Select-Object HostName, @{n='RecordData';e={if ($_.RecordData.IPv4Address.IPAddressToString) {$_.RecordData.IPv4Address.IPAddressToString} else {""}}}

# Generate reverse lookup zone prefixes
foreach ($revZone in $revZones){
    $ipAddressParts = $revZone.ZoneName.Split('.')
    $RevResult += $ipAddressParts[2] + "." + $ipAddressParts[1] + "." + $ipAddressParts[0]
}

# Generate DNS entry prefixes
foreach ($dnsEntrie in $dnsEntries){
    $ipAddressParts = $dnsEntrie.RecordData.Split('.')
    $tmpResult = $ipAddressParts[0] + "." + $ipAddressParts[1] + "." + $ipAddressParts[2]
    if($tmpResult -notcontains ".."){$dnsResult += $tmpResult}
}

# Check missing zones
$MissingZones = $dnsResult | Where-Object {$RevResult -notcontains $_} | Sort-Object | Get-Unique -AsString

# Output results
Write-Host "DNS Server: $DNSServer" -ForegroundColor Green
Write-Host "DNS Zone  : $ZoneToCheck" -ForegroundColor Green
Write-Host "Missing reverse zones" -ForegroundColor Green
Write-Host "-------------------------------------" -ForegroundColor Green
$MissingZones
$MissingZones | Out-File $OutputFile -Verbose