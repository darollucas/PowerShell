<#   
.SYNOPSIS   
   
  Gets DHCP scopes from a list of servers, compiles the data in HTML and sends an email alert if the percentage in use crosses a defined threshold
   
.DESCRIPTION   
    
  This script gets DHCP Scope info from a list of servers, compiles the data in HTML, changes the cell color based on percentage in use and sends an email alert if the percentage in use crosses a defined threshold (95% by default).  
   
.COMPATABILITY    
    
  Requires PS v4. Tested against 2008 to 2012 R2 DHCP servers
     
.EXAMPLE 
  PS C:\> Get-DHCPStats.ps1 
  All options are set as variables in the GLOBALS section so you simply run the script. 
 
.NOTES   
     
  This script requires the DhcpServer module.
 
  This script also requires the sortable.js script if you want to make the table columns sortable. Download the script and place it in the same directory as $OutputFile. Get it here: http://www.kryogenix.org/code/browser/sorttable 
   
  The account running the script or scheduled task obviously must have the appropriate permissions on each server.  
   
  NAME:       Get-DHCPStats.ps1   
   
  AUTHOR:     Brian D. Arnold   
   
  CREATED:    07/02/2014  
   
  LASTEDIT:   05/24/2016  
#>   
 
################### 
##### GLOBALS ##### 
################### 
 
# List and file variables
$ServerList = 'TBIT-DC-01','TBIT-DC-02'
# $ServerList = Get-DhcpServerInDC | Select DnsName #Get all DHCP servers from AD
$OutputFile = "C:\default.htm" 
 
# Get domain name, date and time for report title 
$DomainName = (Get-ADDomain).NetBIOSName  
$Time = Get-Date -Format t 
$CurrDate = Get-Date -UFormat "%D" 

# THreshold variables
$Alert = '95'
$Warn = '80'

# Email SMTP variables - CHANGE BELOW in 'SMTP Settings for Email Report' section

# Option to create transcript - change to $true to turn on.
$CreateTranscript = $false

###############
##### PRE #####
###############

# Start Transcript if $CreateTranscript variable above is set to $true.
if($CreateTranscript)
{
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if( -not (Test-Path ($scriptDir + "\Transcripts"))){New-Item -ItemType Directory -Path ($scriptDir + "\Transcripts")}
Start-Transcript -Path ($scriptDir + "\Transcripts\{0:yyyyMMdd}_Log.txt"  -f $(get-date)) -Append
}
 
# Import modules
Import-Module DhcpServer

################ 
##### MAIN ##### 
################ 

$HTML = '<style type="text/css"> 
#TSHead body {font: normal small sans-serif;}
#TSHead table {border-collapse: collapse; width: 100%; background-color:#F5F5F5;}
#TSHead th {font: normal small sans-serif;text-align:left;padding-top:5px;padding-bottom:4px;background-color:#7FB1B3;}
#TSHead th, td {font: normal small sans-serif; padding: 0.25rem;text-align: left;border: 1px solid #FFFFFF;}
#TSHead tbody tr:nth-child(odd) {background: #D3D3D3;}
    </Style>' 

# Report Header
$Header = "<H2 align=center><font face=Arial>$DomainName DHCP Stats as of $Time on $CurrDate</font></H2>"  
$Header2 = "<H4 align=center><font face=Arial><span style=background-color:#FFF284>WARNING</span> at 80% In Use. <span style=background-color:#FF9797>CRITICAL</span> and email alert sent at 95% In Use.</font></H4>" 

$HTML += "<HTML><BODY><script src=sorttable.js></script><Table border=1 cellpadding=0 cellspacing=0 width=100% id=TSHead class=sortable>
        <TR> 
			<TH><B>DHCP Server</B></TH>
			<TH><B>Scope Name</B></TH>
			<TH><B>Scope State</B></TH>
			<TH><B>In Use</B></TH>
			<TH><B>Free</B></TH>
			<TH><B>% In Use</B></TH>
			<TH><B>Reserved</B></TH>
			<TH><B>Scope ID</B></TH>
			<TH><B>Subnet Mask</B></TH>
			<TH><B>Start of Range</B></TH>
			<TH><B>End of Range</B></TH>
			<TH><B>Lease Duration</B></TH>
        </TR>
        " 

Foreach($Server in $ServerList)
{
$ScopeList = Get-DhcpServerv4Scope -ComputerName $Server
ForEach($Scope in $ScopeList.ScopeID) 
{
    Try{
    $ScopeInfo = Get-DhcpServerv4Scope -ComputerName $Server -ScopeId $Scope
    $ScopeStats = Get-DhcpServerv4ScopeStatistics -ComputerName $Server -ScopeId $Scope | Select-Object ScopeID,AddressesFree,AddressesInUse,PercentageInUse,ReservedAddress
    $ScopeReserved = (Get-DhcpServerv4Reservation -ComputerName $server -ScopeId $scope).count
    }
    Catch{
    }

# SMTP Settings for Email Report
$EmailFrom = "dhcp_alert@contoso.com"
$EmailTo = "dhcpalerts@contoso.com"
$EmailSubject = "$($ScopeInfo.Name) on $Server has $([System.Math]::Round($ScopeStats.PercentageInUse))% IP Addresses In Use" 
$EmailBody = "Description on scope is '$($ScopeInfo.Description)'. Live data: http://dhcpstats.contoso.com/"
$SMTPServer = "smtp.contoso.com"
$SMTPPort = "25"
# Send email if % free falls below 5% 
if($ScopeStats.PercentageInUse -gt $Alert)
{
$Message = New-Object Net.Mail.MailMessage($EmailFrom, $EmailTo, $EmailSubject, $EmailBody)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SMTPPort)
$SMTPClient.Send($Message)
$Message.dispose()
}

# HTML Table values	
                $HTML += "<TR>
                    <TD>$($Server)</TD>
                    <TD>$($ScopeInfo.Name)</TD>
					<TD bgcolor=`"$(if($ScopeInfo.State -eq "Inactive"){"AAAAB2"})`">$($ScopeInfo.State)</TD>
					<TD>$($ScopeStats.AddressesInUse)</TD>
					<TD>$($ScopeStats.AddressesFree)</TD>
                    <TD bgcolor=`"$(if($ScopeStats.PercentageInUse -gt $Alert){"FF9797"}elseif($ScopeStats.PercentageInUse -gt $Warn){"FFF284"}else{"A6CAA9"})`">$([System.Math]::Round($ScopeStats.PercentageInUse))</TD>
                    <TD>$($ScopeReserved)</TD>
					<TD>$($ScopeInfo.ScopeID.IPAddressToString)</TD>
					<TD>$($ScopeInfo.SubnetMask)</TD>
                    <TD>$($ScopeInfo.StartRange)</TD>
                    <TD>$($ScopeInfo.EndRange)</TD>
                    <TD>$($ScopeInfo.LeaseDuration)</TD>
                    </TR>"
} 
}

$HTML += "<H2></Table></BODY></HTML>" 
$Header + $Header2 + $HTML | Out-File $OutputFile

