#Rename NICs
Rename-NetAdapter -Name "NIC1" -NewName "Fabric_A1"
Rename-NetAdapter -Name "NIC2" -NewName "Fabric_A2"
Rename-NetAdapter -Name "Slot 2 Port 1" -NewName "Fabric_B1"
Rename-NetAdapter -Name "Slot 2 Port 2" -NewName "Fabric_B2"

CONFIGURE A FABRIC
#Set NIC VLAN ID
Set-NetAdapterAdvancedProperty -Name "Fabric_A1" -DisplayName "VLAN ID" -DisplayValue 21
Set-NetAdapterAdvancedProperty -Name "Fabric_A2" -DisplayName "VLAN ID" -DisplayValue 21

#CONFIGURE B FABRIC
#SET IP
$B1_IP = '192.168.3.143'
$B2_IP = '192.168.4.143'

#Disable IPv6 for Storage Adapters
Disable-NetAdapterBinding -Name Fabric_B1 -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name Fabric_B2 -ComponentID ms_tcpip6

#Disable DHCP for Storage Adapters
Set-NetIPInterface -InterfaceAlias Fabric_B1 -Dhcp Disabled
Set-NetIPInterface -InterfaceAlias Fabric_B2 -Dhcp Disabled

#Set Adapter Properties Jumbo Packets
set-NetAdapterAdvancedProperty -Name "Fabric_B1" -RegistryKeyword "*JumboPacket" -RegistryValue "9014"
set-NetAdapterAdvancedProperty -Name "Fabric_B2" -RegistryKeyword "*JumboPacket" -RegistryValue "9014"

#Set Adapter VLAN IDs
Set-NetAdapterAdvancedProperty -Name "Fabric_B1" -DisplayName "VLAN ID" -DisplayValue 1923
Set-NetAdapterAdvancedProperty -Name "Fabric_B2" -DisplayName "VLAN ID" -DisplayValue 1924

#Set IP Addresses (Review IP Addresses before running)
New-NetIPAddress -InterfaceAlias 'Fabric_B1' -IPAddress $B1_IP -PrefixLength 24
New-NetIPAddress -InterfaceAlias 'Fabric_B2' -IPAddress $B2_IP -PrefixLength 24

#Confirm Settings Jumbo
Get-NetAdapter -Name Fabric_B1, Fabric_B2 | Get-NetAdapterAdvancedProperty | Where-Object{ $_.DisplayName -like "*jumbo*"}

#Setup iSCSI Connection Service
set-service -name msiscsi -startuptype automatic
start-service msiscsi
get-service -name msiscsi
 
#get host IQN
Get-InitiatorPort

#Add iSCSI target
New-iscsitargetportal -TargetPortalAddress 192.168.3.90
New-iscsitargetportal -TargetPortalAddress 192.168.4.90
$pureiqn = Get-IscsiTarget | select NodeAddress| where{$_ -like "*pure*"}
$ip1923 = Get-NetIPAddress | where{$_.IPAddress -like "192.168.3.*"}
$ip1924 = Get-NetIPAddress | where{$_.IPAddress -like "192.168.4.*"}

Connect-IscsiTarget -NodeAddress $pureiqn.NodeAddress -IsPersistent $true -IsMultipathEnabled $true -InitiatorPortalAddress $ip1923.IPAddress -TargetPortalAddress 192.168.3.90
Connect-IscsiTarget -NodeAddress $pureiqn.NodeAddress -IsPersistent $true -IsMultipathEnabled $true -InitiatorPortalAddress $ip1923.IPAddress -TargetPortalAddress 192.168.3.91
Connect-IscsiTarget -NodeAddress $pureiqn.NodeAddress -IsPersistent $true -IsMultipathEnabled $true -InitiatorPortalAddress $ip1924.IPAddress -TargetPortalAddress 192.168.4.90
Connect-IscsiTarget -NodeAddress $pureiqn.NodeAddress -IsPersistent $true -IsMultipathEnabled $true -InitiatorPortalAddress $ip1924.IPAddress -TargetPortalAddress 192.168.4.91
 
#Check status of MPIO
Get-MPIOAvailableHW
 
#Enable MPIO for iSCSI
Enable-MSDSMAutomaticClaim -BusType "iSCSI"
Mpclaim.exe -s -d

#Change Load balancing policy to LQD 
Mpclaim.exe -l -m 4

#Show all disks
Get-disk