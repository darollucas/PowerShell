<#
.SYNOPSIS
Fixes the quorum in a Failover Cluster by configuring a specified node as the new quorum owner.

.DESCRIPTION
This script interactively prompts the user to enter the name of the node they want to configure as the new quorum owner. It stops the specified node in the Failover Cluster, configures it as the new quorum owner (NodeWeight=1), and displays the current state and weight of each node in the cluster.

.EXAMPLE
.\Fix-ClusterQuorum.ps1

#>

# Check if FailoverClusters module is available
if (-Not (Get-Module -ListAvailable -Name FailoverClusters)) {
    Write-Host "The FailoverClusters module is not available. Please ensure the Failover Clustering feature is installed on this computer."
    return
}

# Prompt user for the name of the node to fix quorum
$NodeToFixQuorum = Read-Host "Enter the name of the node you want to configure as the new quorum owner"

# Stop the node specified by $NodeToFixQuorum
Write-Host "Stopping the node $NodeToFixQuorum..."
Stop-ClusterNode -Name $NodeToFixQuorum

# Start the node specified by $NodeToFixQuorum and configure it as the new quorum owner
Write-Host "Starting the node $NodeToFixQuorum and configuring it as the new quorum owner..."
Start-ClusterNode -Name $NodeToFixQuorum -FixQuorum
(Get-ClusterNode $NodeToFixQuorum).NodeWeight = 1

# Display the current state and weight of each node in the cluster
$nodes = Get-ClusterNode -Cluster $NodeToFixQuorum
$nodes | Format-Table -Property NodeName, State, NodeWeight
