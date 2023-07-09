<#
.SYNOPSIS
Gets DHCP scopes from a list of servers, compiles the data in HTML, and sends an email alert if the percentage in use exceeds a defined threshold.

.DESCRIPTION
This script retrieves DHCP scope information from a list of servers. It prompts the user to enter the name(s) of the DHCP server(s). It then compiles the data into an HTML report, highlighting the percentage in use based on a threshold. If the percentage in use exceeds the threshold, it sends an email alert. The script supports Windows Server 2016 and newer.

.COMPATIBILITY
PowerShell 5.1 and higher. Tested against Windows Server 2016 and newer DHCP servers.

.NOTES
Script Name: Get-DHCPStats.ps1
Created By: Your Name
Date: Enter Date
Version: 1.0

.EXAMPLE
.\Get-DHCPStats.ps1
# Run the script and enter the name(s) of the DHCP server(s) when prompted.

.NOTES
- This script requires the DhcpServer module.
- The script also requires the sortable.js script (included in the same directory) to make the table columns sortable.
- The account running the script should have appropriate permissions on each DHCP server.

#>

# Set the output file path
$OutputFile = "C:\DHCP_Stats.html"

# Threshold variables (percentage)
$AlertThreshold = 95
$WarningThreshold = 80

# Email settings for report
$EmailFrom = "dhcp_alert@example.com"
$EmailTo = "dhcpalerts@example.com"
$EmailSubject = "DHCP Stats Alert: Percentage In Use Exceeded Threshold"
$EmailBody = "Please check the DHCP stats report for details."
$SMTPServer = "smtp.example.com"
$SMTPPort = 25

# Prepare HTML header
$HTMLHeader = @"
<!DOCTYPE html>
<html>
<head>
<style>
table {
  border-collapse: collapse;
  width: 100%;
}

th, td {
  text-align: left;
  padding: 8px;
  border-bottom: 1px solid #ddd;
}

th {
  background-color: #f2f2f2;
}
</style>
</head>
<body>
<h2>DHCP Stats Report for $($ServerList -join ', ')</h2>
"@

# Prepare HTML footer
$HTMLFooter = @"
</table>
</body>
</html>
"@

# Prompt the user to enter the name(s) of the DHCP server(s)
$ServerList = Read-Host -Prompt "Enter the name(s) of the DHCP server(s), separated by commas"

# Convert the user input to an array
$ServerList = $ServerList -split ',' | ForEach-Object { $_.Trim() }

# Import the DhcpServer module
Import-Module DhcpServer

# Initialize the HTML table
$HTMLTable = @"
<table>
<tr>
  <th>DHCP Server</th>
  <th>Scope Name</th>
  <th>Scope State</th>
  <th>In Use</th>
  <th>Free</th>
  <th>% In Use</th>
  <th>Reserved</th>
  <th>Scope ID</th>
  <th>Subnet Mask</th>
  <th>Start of Range</th>
  <th>End of Range</th>
  <th>Lease Duration</th>
</tr>
"@

# Process each DHCP server in the list
foreach ($Server in $ServerList) {
    # Get DHCP scopes
    $Scopes = Get-DhcpServerv4Scope -ComputerName $Server

    foreach ($Scope in $Scopes) {
        # Get DHCP scope statistics
        $Statistics = Get-DhcpServerv4ScopeStatistics -ComputerName $Server -ScopeId $Scope.ScopeID

        # Calculate percentage in use
        $PercentageInUse = [Math]::Round(($Statistics.AddressesInUse / ($Statistics.AddressesInUse + $Statistics.AddressesFree)) * 100)

        # Determine the color based on the percentage in use
        if ($PercentageInUse -gt $AlertThreshold) {
            $Color = "FF0000"   # Red for exceeding alert threshold
            # Send email alert
            Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject -Body $EmailBody -SmtpServer $SMTPServer -Port $SMTPPort
        }
        elseif ($PercentageInUse -gt $WarningThreshold) {
            $Color = "FFA500"   # Orange for exceeding warning threshold
        }
        else {
            $Color = "FFFFFF"   # Default color
        }

        # Add row to the HTML table
        $HTMLTable += @"
<tr>
  <td>$Server</td>
  <td>$($Scope.Name)</td>
  <td>$($Scope.State)</td>
  <td>$($Statistics.AddressesInUse)</td>
  <td>$($Statistics.AddressesFree)</td>
  <td bgcolor="#$Color">$PercentageInUse%</td>
  <td>$($ScopeReserved.Count)</td>
  <td>$($Scope.ScopeID.IPAddressToString)</td>
  <td>$($Scope.SubnetMask)</td>
  <td>$($Scope.StartRange)</td>
  <td>$($Scope.EndRange)</td>
  <td>$($Scope.LeaseDuration)</td>
</tr>
"@
    }
}

# Create the HTML report
$HTMLReport = $HTMLHeader + $HTMLTable + $HTMLFooter

# Save the HTML report to the output file
$HTMLReport | Out-File -FilePath $OutputFile -Encoding UTF8

# Open the HTML report in the default web browser
Start-Process $OutputFile