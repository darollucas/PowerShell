<#
.SYNOPSIS
Registers servers with Azure Arc by installing required modules, setting parameters interactively, and executing the registration script.

.DESCRIPTION
This PowerShell script automates the process of registering servers with Azure Arc. It includes steps for installing necessary PowerShell modules, interactively setting up crucial parameters for Azure Arc registration, connecting to Azure, and finally executing the Arc registration script.

.EXAMPLE
PS> .\RegisterServersWithAzureArcInteractive.ps1

.NOTES
Author: TechBase IT
This script requires PowerShell to be run as an Administrator and interacts with the user for inputting necessary configuration details.
#>

# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit
}

# Step 1: Install the Arc registration script and required PowerShell modules
Register-PSRepository -Default -InstallationPolicy Trusted
Install-Module AzsHCI.ARCinstaller -Force
Install-Module Az.Accounts -Force
Install-Module Az.ConnectedMachine -Force
Install-Module Az.Resources -Force

# Step 2: Interactively set the parameters for Azure Arc registration
$Subscription = Read-Host "Enter your Azure Subscription ID"
$RG = Read-Host "Enter your Azure Resource Group name"
$Region = Read-Host "Enter the Azure Region for Arc registration (e.g., eastus)"
$Tenant = Read-Host "Enter your Azure Tenant ID"

# Step 3: Connect to your Azure account and set the subscription
Write-Host "Please open a browser on any device and go to https://microsoft.com/devicelogin to authenticate."
Connect-AzAccount -SubscriptionId $Subscription -TenantId $Tenant -UseDeviceAuthentication

#Get the Access Token for the registration
$ARMtoken = (Get-AzAccessToken).Token

#Get the Account ID for the registration
$id = (Get-AzContext).Account.Id

# Step 4: Execute the Arc registration script
# Note: The actual command to run the Arc registration might vary based on the module's documentation or your specific requirements.
# The placeholder below assumes a cmdlet from the AzsHCI.ARCinstaller module. Replace it with the actual command as needed.
Write-Host "Starting Azure Arc registration process..."
Start-AzsHCIARCregistration -SubscriptionId $Subscription -ResourceGroupName $RG -Location $Region -TenantId $Tenant -ArmToken $ARMtoken -AccountId $id

Write-Host "Azure Arc registration process has been initiated. Please follow any additional instructions on your screen."
