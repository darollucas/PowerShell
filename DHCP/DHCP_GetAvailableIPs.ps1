<#
.SYNOPSIS
Exports detailed information about DHCP scopes, including IP usage, reservations, and available IPs.

.DESCRIPTION
This script retrieves information about all DHCP scopes on a Windows Server, including:
- Total IPs in the scope
- Leased IPs
- Reserved IPs
- Available IPs (after accounting for leased and reserved IPs)

The script exports the data to a CSV file for easy analysis.

.NOTES
Author: Your Name
Date: 2023-10-05
Version: 1.0

.LINK
Documentation: <link_to_documentation>

.EXAMPLE
PS> .\Export-DhcpReport.ps1
Exports DHCP scope information to 'C:\DHCP_Report.csv'.
#>

# Define the output file path
$outputFile = "C:\DHCP_Report.csv"

# Get all DHCP scopes
$scopes = Get-DhcpServerv4Scope

# Initialize an array to store the report data
$report = @()

# Function to calculate total IPs based on subnet mask
function Get-TotalIPs {
    param (
        [string]$SubnetMask
    )
    # Convert subnet mask to binary and count the number of '1's
    $maskBytes = [ipaddress]::Parse($SubnetMask).GetAddressBytes()
    $prefixLength = 0
    foreach ($byte in $maskBytes) {
        $prefixLength += [convert]::ToString($byte, 2).TrimEnd('0').Length
    }
    # Calculate total IPs using the prefix length
    return [math]::Pow(2, 32 - $prefixLength)
}

# Loop through each scope and gather information
foreach ($scope in $scopes) {
    $scopeId = $scope.ScopeId
    $scopeName = $scope.Name
    $subnetMask = $scope.SubnetMask
    $startRange = $scope.StartRange
    $endRange = $scope.EndRange

    # Calculate total IPs in the scope based on subnet mask
    $totalIPs = Get-TotalIPs -SubnetMask $subnetMask

    # Get the number of leased IPs
    $leasedIPs = (Get-DhcpServerv4Lease -ScopeId $scopeId -AllLeases | Where-Object { $_.AddressState -eq "Active" }).Count

    # Get the number of reservations
    $reservations = (Get-DhcpServerv4Reservation -ScopeId $scopeId).Count

    # Calculate available IPs (Total IPs - Leased IPs - Reservations)
    $availableIPs = $totalIPs - $leasedIPs - $reservations

    # Add scope information to the report
    $report += [PSCustomObject]@{
        ScopeId        = $scopeId
        ScopeName      = $scopeName
        SubnetMask     = $subnetMask
        StartRange     = $startRange
        EndRange       = $endRange
        TotalIPs       = $totalIPs
        LeasedIPs      = $leasedIPs
        Reservations   = $reservations
        AvailableIPs   = $availableIPs
    }
}

# Export the report to a CSV file
$report | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "DHCP report exported to $outputFile"