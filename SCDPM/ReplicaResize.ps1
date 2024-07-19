<#
.SYNOPSIS
    This script resizes the replica volume for a specified data source on a System Center Data Protection Manager (SCDPM) 2022 server.

.DESCRIPTION
    The script connects to the SCDPM 2022 server, retrieves the list of data sources, and allows the user to select a data source to resize the replica volume.
    The user is prompted to enter the new replica size in GB. The script then updates the replica size and logs the actions.

.NOTES
    Author: Your Name
    Version: 2.0
    Date: 2024-06-15

.PARAMETER DpmServer
    The name of the DPM server.

.PARAMETER LogFile
    The path to the log file where actions will be logged.
#>
#Resized Replica Volume located on DPM 2016 +UR1 Modern Backup Storage.

$version="V1.0"

$ErrorActionPreference = "silentlycontinue"



[uint64] $GB=1048576000 #Multiple of 10MB

$logfile="ResizeReplica.LOG"

$confirmpreference = "None"



function Show_help

{

cls

write-host "Version: $version" -foregroundcolor cyan

write-host "Script Usage" -foregroundcolor green

write-host "A: Script lists all protected data sources plus current Replica size." -foregroundcolor green
write-host "B: User Selects data source to resize replica for." -foregroundcolor green

write-host "C: User enters new Replica Size in GB." -foregroundcolor green

write-host "Appending inputs and results to log file $logfile`n" -foregroundcolor white

}

"" >>$logfile

"**********************************" >> $logfile

"Version $version" >> $logfile

get-date >> $logfile

show_help

$C=Read-Host "`nThis script is only intended to be ran on DPM 2016 + UR1 or later - Press C to continue. "

write-host $line -foregroundcolor white
$line = "This script is only intended to be ran on DPM 2016 + UR1 or later - Press C to continue."

$line = $line + $C

$line >> $logfile

if ($C -NotMatch "C")

{

write-host "Exiting...."

Exit 0

}

write-host "User Accepts all responsibilities by entering a data source" -foregroundcolor white -backgroundcolor blue


$DPM = Connect-dpmserver -Dpmservername (&hostname)

$DPMservername = (&hostname)

"Selected DPM server = $DPMservername" >> $logfile

write-host "`nRetrieving list of data sources on $Dpmservername`n" -foregroundcolor green

$pglist = @(Get-ProtectionGroup $DPMservername) # Created PGlist as array in case we have a single protection group.

$ds=@()
$count = 0

$dscount = 0

foreach ($count in 0..($pglist.count - 1))

{

$ds += @(get-datasource $pglist[$count]) # Created DS as array in case we have a single protection group.

}

if ( Get-Datasource $DPMservername -inactive) {$ds += Get-Datasource $DPMservername -inactive}



$i=0

write-host "Index Protection Group     Computer             Path                                     Replica-Size Bytes"

write-host "-----------------------------------------------------------------------------------------------------------"

foreach ($l in $ds)

{

"[{0,3}] {1,-20} {2,-20} {3,-40} {4}" -f $i, $l.ProtectionGroupName, $l.psinfo.netbiosname, $l.logicalpath, $l.replicasize

$i++
}

$DSname=read-host "`nEnter a data source index number from the list above."

write-host ""

if (!$DSname)

{

write-host "No datasource selected, exiting.`n" -foregroundcolor yellow

"Aborted on no Datasource index selected" >> $logfile

exit 0

}

$DSselected=$ds[$DSname]

if (!$DSselected)

{

write-host "No valid datasource selected, exiting. `n" -foregroundcolor yellow

"Aborted on invalid Datasource index number" >> $logfile

exit 0
}



if ($DSselected.Replicasize -gt 0)

{

$Replicasize=[math]::round($DSselected.Replicasize/$GB,1)

$line=("Current Replica Size = {0} GB for selected data source: $DSselected.name" -f $Replicasize)

$line >> $logfile

write-host $line`n -foregroundcolor white

}


[uint64] $NewReplicaGB=read-host "Enter new Replica size in GB"

if ($Replicasize -ge $NewReplicaGB)
{

write-host New Replica size must be greater than current size of $Replicasize GB - Exiting.

$line =("New Replica size must be greater than current size - Exiting")

$line >> $logfile

exit 0

}

$line=("Processing Replica Resize Request of {0} GB.  Please wait..." -f $NewReplicaGB)

$line >> $logfile

write-host $line`n -foregroundcolor white



# execute the resize

Edit-DPMDiskAllocation -DataSource $DSSelected -ReplicaSize ($NewReplicaGB*$GB)



$line = "Resize Process Done ! "

write-host $line
$datetime = get-date

$line = $line + $datetime

$line >> $logfile

$line="Do you want to View $logfile file Y/N ? "

write-host $line -foregroundcolor white

$Y=read-host

$line = $line + $Y

$line >> $logfile

if ($Y -ieq "Y")

{

Notepad $logfile

}