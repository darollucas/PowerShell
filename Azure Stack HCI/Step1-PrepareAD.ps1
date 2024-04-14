<#
.SYNOPSIS
Prepares Active Directory for Azure Stack HCI 23H2 deployment.

.DESCRIPTION
This PowerShell script automates the preparation of Active Directory for deploying Azure Stack HCI 23H2 by creating necessary AD objects using the AsHciADArtifactsPreCreationTool module. It prompts for user input to specify the OU and credentials, aligning with Microsoft's guidelines for Azure Stack HCI deployment. Intended to be run on a domain controller or with equivalent permissions.

.EXAMPLE
PS> .\PrepareADForAzureStackHCI.ps1

.NOTES
Author: TechBase IT
Date: 04/13/2024
This script must be run with Domain Admin privileges or equivalent permissions necessary to modify Active Directory objects. Follows Microsoft's documentation for preparing Active Directory for Azure Stack HCI deployment.
If you are repairing a single server, do not delete the existing OU. If the server volumes are encrypted, deleting the OU removes the BitLocker recovery keys.
When group policy inheritance is blocked at the OU level, enforced GPO's aren't blocked. Ensure that any applicable GPO, which are enforced, are also blocked using other methods, for example, using WMI Filters or security groups.
Deployment Checklist - https://learn.microsoft.com/en-us/azure-stack/hci/deploy/deployment-prerequisites#complete-deployment-checklist
#>

# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit
}

# Import Active Directory module
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Install-WindowsFeature -Name RSAT-AD-PowerShell
}
Import-Module ActiveDirectory

# Install and Import the AsHciADArtifactsPreCreationTool module
if (-not (Get-Module -ListAvailable -Name AsHciADArtifactsPreCreationTool)) {
    Write-Host "Installing AsHciADArtifactsPreCreationTool module from PowerShell Gallery..."
    Install-Module -Name AsHciADArtifactsPreCreationTool -Force
}
Import-Module AsHciADArtifactsPreCreationTool

# Prompt for the OU name or distinguished name including the domain components
$AsHciOUName = Read-Host "Please enter the OU name or distinguished name for the Azure Stack HCI deployment (e.g., 'OU=AzureStackHCI,DC=yourdomain,DC=com')"

# Get Azure Stack HCI deployment user credential
$AzureStackLCMUserCredential = Get-Credential -Message "Enter credentials for the Azure Stack HCI deployment user"

# Create necessary AD objects for Azure Stack HCI deployment
New-HciAdObjectsPreCreation -AzureStackLCMUserCredential $AzureStackLCMUserCredential -AsHciOUName $AsHciOUName

Write-Host "Active Directory preparation for Azure Stack HCI deployment is complete."