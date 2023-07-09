<#
.SYNOPSIS
A script to delete and recreate the _msdcs DNS zone on a Windows DNS server.

.DESCRIPTION
This script deletes and recreates the _msdcs DNS zone on a Windows DNS server. It's used when troubleshooting problems involving the _msdcs zone.

This script requires administrative privileges to run.

.EXAMPLE
.\Recreate-MsdcsZone.ps1 
#>

# Function to delete and recreate _msdcs DNS zone
Function Recreate-MsdcsZone
{
    # Import necessary modules
    Import-Module DnsServer

    # Request the domain name from the user
    $domain = Read-Host "Please enter the name of your domain"

    # Specify the DNS zone name
    $dnsZone = "_msdcs.$domain"

    # Print a reminder to back up the existing data
    Write-Output "IMPORTANT: Please back up the existing data before proceeding. For non-AD-integrated zones, copy the contents of the %windir%\System32\dns folder. For AD-integrated zones, back up the system state of a DC that is also a DNS server."

    # Wait for the user to confirm that they have backed up the data
    $confirm = Read-Host "Have you backed up the existing data? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Output "Please back up the data and run the script again."
        return
    }

    # Delete the _msdcs DNS zone
    Remove-DnsServerZone -Name $dnsZone -Confirm:$false

    # Recreate the _msdcs DNS zone
    Add-DnsServerPrimaryZone -Name $dnsZone -ReplicationScope "Forest"

    # Restart the DNS Server service
    Restart-Service -Name "DNS"

    # Flush and register DNS
    ipconfig /flushdns
    ipconfig /registerdns

    # Restart Netlogon service
    net stop netlogon
    net start netlogon

    Write-Output "Recreation of _msdcs zone is completed. Please wait a few minutes and check the DNS console."
}

# Run the function
Recreate-MsdcsZone
