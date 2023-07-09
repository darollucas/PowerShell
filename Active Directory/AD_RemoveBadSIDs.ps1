<#
.SYNOPSIS
This script analyzes and removes objects with unknown SIDs from Active Directory. It provides options to list or remove objects, specify the target folder, and show access permissions for analyzed objects.

.DESCRIPTION
The script analyzes Active Directory objects and identifies objects with unknown SIDs. It offers the flexibility to list or remove the identified objects. You can specify the target folder for analysis, and optionally display access permissions for the analyzed objects.

.PARAMETER Action
Specifies the action to perform. Options are: /LIST, /REMOVE, /LISTOU, /REMOVEOU.

.PARAMETER Folder
Specifies the target folder for analysis. Options include: /DOMAIN, /CONF, /SCHEMA, /DOMAINDNS, /FORESTDNS, or a specific DN between double-quotes.

.PARAMETER Opt
Specifies additional options. Options are: /RO to list or remove only objects with unknown SIDs of the domain, and /SP to display access permissions for all analyzed objects.

.NOTES
Script Name: RemoveBadSID-AD.ps1
Created By: TechBase IT
Version: 1.0

.EXAMPLE
.\RemoveBadSID-AD.ps1 /REMOVEOU /DOMAIN /RO
# Clean only CNs and OUs with unknown SIDs in the current domain.

.EXAMPLE
.\RemoveBadSID-AD.ps1 /LIST "OU=MySite,DC=Domain,DC=local"
# List all objects in the specified OU for analysis.

#>

param (
    [string]$Action,
    [string]$Folder,
    [string]$Opt
)

$Forest = Get-ADRootDSE
$Domain = (Get-ADDomain).DistinguishedName
$Conf = $Forest.ConfigurationNamingContext
$Schema = $Forest.SchemaNamingContext
$ForestName = $Forest.RootDomainNamingContext
$DomainDNS = "DC=DomainDnsZones,$ForestName"
$ForestDNS = "DC=ForestDnsZones,$ForestName"

$domsid = (Get-ADDomain).DomainSID.ToString()

if (($Action) -and ($Action.ToUpper() -like "/LIST")) {
    $Remove = $False
    $OU = $False
} elseif (($Action) -and ($Action.ToUpper() -like "/LISTOU")) {
    $Remove = $False
    $OU = $True
} elseif (($Action) -and ($Action.ToUpper() -like "/REMOVE")) {
    $Remove = $True
    $OU = $False
} elseif (($Action) -and ($Action.ToUpper() -like "/REMOVEOU")) {
    $Remove = $True
    $OU = $True
} else {
    Write-Host -BackgroundColor 'White' -ForegroundColor 'Blue' "SYNTAX: RemoveBadSID-AD.ps1 [/LIST|/REMOVE|/LISTOU|/REMOVEOU[/DOMAIN|/CONF|/SCHEMA|/DOMAINDNS|/FORESTDNS|dn[/RO|/SP]]]"
    Write-Host -BackgroundColor 'White' -ForegroundColor 'Blue' "PARAM1: /LISTOU List only CNs&OUs /LIST List all objects, /REMOVE Clean all objects /REMOVEOU Clean only CNs&OUs"
    Write-Host -BackgroundColor 'White' -ForegroundColor 'Blue' "PARAM2: /DOMAIN Actual domain /CONF Conf. Part./SCHEMA /DOMAINDNS /FORESTDNS or a specific DN between double-quotes"
    Write-Host -BackgroundColor 'White' -ForegroundColor 'Blue' "OPTION1: /RO lists/Removes only objects with unknown SIDs of the domain"
    Write-Host -BackgroundColor 'White' -ForegroundColor 'Blue' "OPTION2: /SP lists access permissions for all analyzed objects"
    Write-Host -BackgroundColor 'White' -ForegroundColor 'Blue' "If no DN is indicated, the current domain will be used"
    Write-Host -BackgroundColor 'White' -ForegroundColor 'Blue' "SAMPLE1 : RemoveBadSID-AD.ps1 /REMOVEOU /DOMAIN /RO"
    Write-Host -BackgroundColor 'White' -ForegroundColor 'Blue' 'SAMPLE2 : RemoveBadSID-AD.ps1 /LIST "OU=MySite,DC=Domain,DC=local"'
    Break
}

if (($Folder) -and ($Folder.ToUpper() -like "/CONF")) {
    $Folder = $Conf
} elseif (($Folder) -and ($Folder.ToUpper() -like "/SCHEMA")) {
    $Folder = $Schema
} elseif (($Folder) -and ($Folder.ToUpper() -like "/DOMAIN")) {
    $Folder = $Domain
} elseif (($Folder) -and ($Folder.ToUpper() -like "/DOMAINDNS")) {
    $Folder = $DomainDNS
} elseif (($Folder) -and ($Folder.ToUpper() -like "/FORESTDNS")) {
    $Folder = $ForestDNS
} elseif (($Folder) -and ($Folder.ToUpper() -match "DC=*")) {
    Write-output "This DistinguishedName will be analyzed: $Folder"
} else {
    $Folder = $Domain
    Write-output "This current domain will be analyzed: $Domain"
}

Write-output "Analyzing the following object: $Folder"

if (($Opt) -and ($Opt.ToUpper() -like "/RO")) {
    $Show = $False
} else {
    $Show = $True
}

if (($Opt) -and ($Opt.ToUpper() -like "/SP")) {
    $ShowPerms = $True
} else {
    $ShowPerms = $False
}

# Functions list

function RemovePerms {
    param ($fold)

    $f = Get-Item AD:$fold
    $fName = $f.DistinguishedName

    if ($Show) {
        Write-output $fname
    }

    $x = [System.DirectoryServices.ActiveDirectorySecurity](Get-ACL AD:$f)

    if ($ShowPerms) {
        Write-output $x.Access | Sort-Object -Property IdentityReference -Unique | Format-Table -Auto IdentityReference, IsInherited, AccessControlType, ActiveDirectoryRights
    }

    $mod = $false
    $OldSID = ""

    foreach ($i in $x.Access) {