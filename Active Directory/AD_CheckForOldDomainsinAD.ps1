<#
.SYNOPSIS
This PowerShell script searches Active Directory, DNS, and ADSIEdit for specified old domain names that should not be present in the environment.

.DESCRIPTION
The script prompts the user to enter the current domain name, the DNS server, and the old domain names to search for. It then searches Active Directory, DNS, and ADSIEdit for the specified old domain names and displays the results.

.PARAMETER None
No parameters are required. The script will interactively prompt the user for input.

.EXAMPLE
.\Search-OldDomainNames.ps1
#>

# Prompt for the current domain name
$currentDomain = Read-Host "Enter the current domain name (e.g., internaldomain.com)"

# Prompt for the DNS server
$dnsServer = Read-Host "Enter the DNS server"

# Prompt for the old domain names to search for
$oldDomainNames = @()
do {
    $oldDomain = Read-Host "Enter an old domain name to search for (or type 'done' to finish)"
    if ($oldDomain -ne 'done' -and $oldDomain -ne '') {
        $oldDomainNames += $oldDomain
    }
} until ($oldDomain -eq 'done')

# Retrieve naming contexts from RootDSE
$rootDSE = Get-ADRootDSE -Server $currentDomain
$namingContexts = $rootDSE.namingContexts

# Search Active Directory for old domain names
$adResults = $namingContexts | Where-Object { $oldDomainNames -contains $_ } | ForEach-Object { "CN=$_" }

# Search DNS for old domain names
try {
    $dnsResults = Get-DnsServerResourceRecord -ZoneName $currentDomain -ComputerName $dnsServer | Where-Object { $_.RecordType -eq "NS" -and $oldDomainNames -contains $_.HostName } | Select-Object -ExpandProperty HostName
}
catch {
    Write-Warning "Failed to retrieve DNS zone information for $currentDomain on server $dnsServer."
    $dnsResults = @()
}

# Search ADSIEdit for old domain names
$adsiResults = $namingContexts | Where-Object { $oldDomainNames -contains $_ } | ForEach-Object { "CN=$_" }

# Display the results
Write-Host "Old domain names found in Active Directory:"
$adResults | ForEach-Object { Write-Host " - $_" }

Write-Host "Old domain names found in DNS:"
$dnsResults | ForEach-Object { Write-Host " - $_" }

Write-Host "Old domain names found in ADSIEdit:"
$adsiResults | ForEach-Object { Write-Host " - $_" }
