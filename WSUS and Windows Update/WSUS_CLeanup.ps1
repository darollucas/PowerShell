#Requires -Version 3.0
################################
#        WSUSClean             #
#         Version 3.2          #
#                              #
#   The last WSUS Script you   #
#       will ever need!        #
#                              #
#                              #
#                              #
################################
<#
################################
#  End User License Agreement  #
################################


################################
#         Prerequisites        #
################################

1. This script has to be saved as plain text in ANSI format. If you use Notepad++, you might need to
   change the encoding to ANSI (Encoding > 'Encode in ANSI' or Encode > 'Convert to ANSI').
   An easy way to tell if it is saved in plain text (ANSI) format is that there is a #Requires
   statement at the top of the script. Make sure that there is a hyphen before the word
   "Version" and you shouldn't have a problem with executing it. If you end up with an error
   like below, it is due to the encoding of the file as you can tell by the Ã¢â‚¬â€œ characters
   before the word Version.

   At C:\Scripts\Clean-WSUS.ps1:1 char:13
   + #Requires Ã¢â‚¬â€œVersion 3.0

2. You must run this on the WSUS Server itself and any downstream WSUS servers you may have.
   It does not matter the order on where you run it as the script takes care of everything
   for you.

3. On the WSUS Server, you must install the SQL Server Management Studio (SSMS) from Microsoft
   so that you have the SQLCMD utility. The SSMS is not a requirement but rather a good tool for
   troubleshooting if needed. The bare minimum requirement is the Microsoft Command Line
   Utilities for SQL Server at whatever version yours is.

4. You must have PowerShell 3.0 or higher installed. I recommend version 4.0 or higher.

    Prerequisite Downloads
    ----------------------

    - For Server 2008 SP2:
        - Install Windows PowerShell from Server Manager - Features
        - Install .NET 3.5 SP1 from - https://www.microsoft.com/en-ca/download/details.aspx?id=25150
        - Install SQL Server Management Studio from https://www.microsoft.com/en-ca/download/details.aspx?id=30438
          You want to choose SQLManagementStudio_x64_ENU.exe
        - Install .NET 4.0 - https://www.microsoft.com/en-us/download/details.aspx?id=17718
        - Install PowerShell 2.0 & WinRM 2.0 from https://www.microsoft.com/en-ca/download/details.aspx?id=20430
        - Install Windows Management Framework 3.0 from https://www.microsoft.com/en-ca/download/details.aspx?id=34595

    - For Server 2008 R2:
        - Install .NET 4.5.2 from https://www.microsoft.com/en-ca/download/details.aspx?id=42642
        - Install Windows Management Framework 4.0 and reboot from https://www.microsoft.com/en-ca/download/details.aspx?id=40855
        - Install SQL Server Management Studio from https://www.microsoft.com/en-ca/download/details.aspx?id=30438
          You want to choose SQLManagementStudio_x64_ENU.exe

    - For SBS 2008: This script WILL work on SBS 2008 - you just have to install the prerequisites below.
                    .NET 4 is backwards compatible and I have a lot of users who have installed it on SBS 2008 and use the script.
        - Install Windows PowerShell from Server Manager - Features
        - Install .NET 3.5 SP1 from - https://www.microsoft.com/en-ca/download/details.aspx?id=25150
        - Install SQL Server Management Studio from https://www.microsoft.com/en-ca/download/details.aspx?id=30438
          You want to choose SQLManagementStudio_x64_ENU.exe
        - Install .NET 4.0 - https://www.microsoft.com/en-us/download/details.aspx?id=17718
        - Install PowerShell 2.0 & WinRM 2.0 from https://www.microsoft.com/en-ca/download/details.aspx?id=20430
        - Install Windows Management Framework 3.0 from https://www.microsoft.com/en-ca/download/details.aspx?id=34595
        - See "A note to SBS users:" Below

    - For SBS 2011: This script WILL work on SBS 2011 - you just have to install the prerequisites below.
                    .NET 4 is backwards compatible and I have a lot of users who have installed it on SBS 2011 and use the script.
        - Install .NET 4.5.2 from https://www.microsoft.com/en-ca/download/details.aspx?id=42642
        - Install Windows Management Framework 4.0 and reboot from https://www.microsoft.com/en-ca/download/details.aspx?id=40855
        - Install SQL Server Management Studio from https://www.microsoft.com/en-ca/download/details.aspx?id=30438
          You want to choose SQLManagementStudio_x64_ENU.exe
        - See "A note to SBS users:" Below

    - For Server 2012 & 2012 R2
        - Install SQL Server Management Studio from https://www.microsoft.com/en-us/download/details.aspx?id=29062
          You want to choose the ENU\x64\SQLManagementStudio_x64_ENU.exe

    - For Server 2016
        - I've not personally tested this on server 2016, however many people have run it without issues on Server 2016.
          I don't think Microsoft has changed much between 2012 R2 WSUS and 2016 WSUS.
        - Install SQL Server Management Studio from https://msdn.microsoft.com/library/mt238290.aspx

    IF YOU DON'T WANT TO INSTALL SQL SERVER MANAGEMENT STUDIO:
    Microsoft Command Line Utilities for SQL Server (Minimum requirement instead of SQL Server Management Studio)
        SQL 2008/2008R2 - https://www.microsoft.com/en-ca/download/details.aspx?id=16978
        SQL 2012/2014 - Version 11 - https://www.microsoft.com/en-us/download/details.aspx?id=36433
                      - ODBC Driver Version 11 - https://www.microsoft.com/en-gb/download/details.aspx?id=36434
        SQL 2016 - Version 13 - https://www.microsoft.com/en-us/download/details.aspx?id=53591

    A note to SBS users:
        For those of you who have already Googled and have read that there are compatibility issues with PowerShell 3.0
        or 4.0 and/or Windows Management Framework 3.0 or 4.0 and have seen all of the release notes and posts saying
        not to install these on SBS, please take notes of the dates of these pages and advice notes. Most of these are
        relying on and regurgitating old information. If a site has a recent post that says not to install it as there
        are compatibility issues, find their source of information and if you follow the source, you'll notice that
        they are regurgitating a post from years ago. When you are reading things on the Internet, think critically,
        look at dates, and use your intelligence to figure out if it still makes sense. Don't blindly rely on words
        on pages of the internet.

        An example is .NET 4.7 which was released 2017.06.15 and which has a warning to not install .NET 4.7 on an
        Exchange server. This holds true until it can be properly tested, and if issues found, patches to .NET 4.7.x
        released for compatibility with Exchange. The biggest issue - all previous forums, blogs and writings on the
        Internet will not be updated to say that .NET 4.7 is now compatible to install on Exchange servers. This
        showcases my point that imagine in 2019 someone who is thinking about updating an Exchange server, Googling
        to find out if .NET 4.7 is compatible (when current version of .NET is probably around version 5.0 or 5.1)
        and finding all these warnings about not installing it on an Exchange server.

        One note for any system, but something to mention specifically for this thought:
        The best thing you can do is make sure your system is updated. Non-updated systems suffer problems and exploits
        that in the end, cause you more time in troubleshooting and fixing than to keep systems updated.

################################
#         Instructions         #
################################

 1. Edit the variables below to match your environment (It's only email server settings if you
    use my default settings)
 2. Open PowerShell using "Run As Administrator" on the WSUS Server.
 3. Because you downloaded this script from the internet, you cannot initially run it directly
    as the ExecutionPolicy is default set to "Restricted" (Server 2008, Server 2008 R2, and
    Server 2012) or "RemoteSigned" (Server 2012 R2).  You must change your ExecutionPolicy to
    Bypass. You can do this with Set-ExecutionPolicy, however that will change it globally for
    the server, which is not recommended. Instead, launch another PowerShell.exe with the
    ExecutionPolicy set to bypass for just that session. At your current PowerShell prompt,
    type in the following and then press enter:

        PowerShell.exe -ExecutionPolicy Bypass

 3. Run the script using -FirstRun.

        .\Clean-WSUS.ps1 -FirstRun

You can use Get-Help .\Clean-WSUS.ps1 for more information.
#>

<#
.SYNOPSIS
This is the last WSUS Script you will ever need. It cleans up WSUS and runs all the maintenance scripts to keep WSUS running at peak performance.

.DESCRIPTION
################################
#    Background Information    #
#          on Streams          #
################################

All my recommendations are set in -ScheduledRun.

WSUSClean WSUS Index Optimization Stream
-----------------------------------------------------

This stream will add the necessary SQL Indexes into the SUSDB Database that make WSUS work about
1,000 to 1,500 times faster on many database operations, making your WSUS installation better
than what Microsoft has left us with.

This stream will be run first on -FirstRun to ensure the rest of the script doesn't take as long
as it has in prior times.

You can use -WSUSIndexOptimization to run this manually from the command-line.

WSUSClean Remove WSUS Drivers Stream
-----------------------------------------------------

This stream will remove all WSUS Drivers Classifications from the WSUS database.
This has 2 possible running methods - Run through PowerShell, or Run directly in SQL.
The -FirstRun Switch will force the SQL method, but all other automatic runs will use the
PowerShell method. I recommend this be done every quarter.

You can use -RemoveWSUSDriversSQL or -RemoveWSUSDriversPS to run these manually from the command-line.

WSUSClean Remove Obsolete Updates Stream
-----------------------------------------------------

This stream will use SQL code to execute pre-existing stored procedures that will return the update id
of each obsolete update in the database and then remove it. There is no magic number of obsolete updates
that will cause the server to time-out. Running this stream can easily take a couple of hours to delete
the updates. While the process is running you might see WSUS synchronization errors. I recommend that
this be done monthly.

You can use -RemoveObsoleteUpdates to run this manually from the command-line.

WSUSClean Compress Update Revisions Stream
-----------------------------------------------------

This stream will use SQL code to execute pre-existing stored procedures that will return the update id
of each update revision that needs compressing and then compress it. I recommend that this be done
monthly.

You can use -CompressUpdateRevisions to run this manually from the command-line.

WSUSClean Decline Multiple Types Of Updates Stream
-----------------------------------------------------

This stream will decline multiple types of updates: Superseded, Expired, and Itanium to name a few.
This is configurable on a per-type basis for inclusion or exclusion when the stream is run.

I recommend that this stream be run every month.

You can use -DeclineMultipleTypesOfUpdates to run this manually from the command-line.

### A note about the default types of updates to be removed. ###

Expired: Decline updates that have been pulled by Microsoft.
Itanium: Decline updates for Itanium computers.
Beta: Decline updates for beta products and beta updates.
Superseded: Decline updates that are superseded and not yet declined.
Preview: Decline preview updates as preview updates may contain bugs because they are not the finished product.

### Please read the background information below on superseded updates for more details. ###

This will be the biggest factor in shrinking down the size of your WSUS Server. Any update that
has been superseded but has not been declined is using extra space. This will save you GB of data
in your WsusContent folder. A superseded update is a complete replacement of a previous release
update. The superseding update has everything that the superseded update has, but also includes
new data that either fixes bugs, or includes something more.

The Server Cleanup Wizard (SCW) declines superseded updates, only if:

    The newest update is approved, and
    The superseded updates are Not Approved, and
    The superseded update has not been reported as NotInstalled (i.e. Needed) by any computer in the previous 30 days.

There is no feature in the product to automatically decline superseded updates on approval of the newer update,
and in fact, you really do not want that feature. The "Best Practice" in dealing with this situation is:

1. Approve the newer update.
2. Verify that all systems have installed the newer update.
3. Verify that all systems now report the superseded update as Not Applicable.
4. THEN it is safe to decline the superseded update.

To SEARCH for superseded updates, you need only enable the Superseded flag column in the All Updates view, and sort on that column.

There will be four groups:

1. Updates which have never been superseded (blank icon).
2. Updates which have been superseded, but have never superseded another update (icon with blue square at bottom).
3. Updates which have been superseded and have superseded another update (icon with blue square in middle).
4. Updates which have superseded another update (icon with blue square at top).

There's no way to filter based on the approval status of the updates in group #4, but if you've verified that all
necessary/applicable updates in group #4 are approved and installed, then you'd be free to decline groups #2 and #3 en masse.

If you decline superseded updates using the method described:

1. Approve the newer update.
2. Verify that all systems have installed the newer update.
3. Verify that all systems now report the superseded update as Not Applicable.
4. THEN it is safe to decline the superseded update.

### THIS SCRIPT DOES NOT FOLLOW THE ABOVE GUIDELINES. IT WILL JUST DECLINE ANY SUPERSEDED UPDATES. ###

WSUSClean Clean Up WSUS Synchronization Logs Stream
-----------------------------------------------------

This stream will remove all synchronization logs beyond a specified time period. WSUS is lacking the ability
to remove synchronization logs through the GUI. Your WSUS server will become slower and slower loading up
the synchronization logs view as the synchronization logs will just keep piling up over time. If you have
your synchronization settings set to synchronize 4 times a day, it would take less than 3 months before you
have over 300 logs that it has to load for the view. This is very time consuming and many just ignore this
view and rarely go to it. When they accidentally click on it, they curse. I recommend that this be done daily.

You can use -CleanUpWSUSSynchronizationLogs to run this manually from the command-line.

WSUSClean Remove Declined WSUS Updates Stream
-----------------------------------------------------

This stream will remove any Declined WSUS updates from the WSUS Database. This is good if you are removing
Specific products (Like Server 2003 / Windows XP updates) from the WSUS server under the Products and
Classifications section. Since this will remove them from the database, if they are still valid, and you
want them to re-appear, you will have to re-add them using 1 of 2 methods. Use the 'Import Update' option
from within the WSUS Console to install specific updates through the Windows Catalog, or remove the product
family, sync, re-select the product family, and then the next synchronizations will pick up the updates
again, along with everything else in that product family. I recommend that this be done every quarter.
This stream is NOT included on -FirstRun on purpose.

You can use -RemoveDeclinedWSUSUpdates to run this manually from the command-line.

WSUSClean Computer Object Cleanup Stream
-----------------------------------------------------

This stream will find all computers that have not synchronized with the server within a certain time period
and remove them. This is usually done through the Server Cleanup Wizard (SCW), however the SCW has been
hard-coded to 30 days. I've setup this stream to be configurable. You can also tell it not to delete any
computer objects if you really want to. The default I've kept at 30 days. I recommend that this be done daily.

You can use -ComputerObjectCleanup to run this manually from the command-line.

WSUSClean WSUS Database Maintenance Stream
-----------------------------------------------------

This stream will perform basic maintenance tasks on SUSDB, the WSUS Database. It will identify indexes
that are fragmented and defragment them. For certain tables, a fill-factor is set in order to improve
insert performance. It will then update potentially out-of-date table statistics. I recommend that this
be done daily.

You can use -WSUSDBMaintenance to run this manually from the command-line.

WSUSClean Server Cleanup Wizard Stream
-----------------------------------------------------

The Server Cleanup Wizard (SCW) is integrated into the WSUS GUI, and can be used to help you manage your
disk space. This runs the SCW through PowerShell which has the added bonus of not timing out as often
the SCW GUI would.

This wizard can do the following things:
    - Remove unused updates and update revisions
      The wizard will remove all older updates and update revisions that have not been approved.

    - Delete computers not contacting the server
      The wizard will delete all client computers that have not contacted the server in thirty days or more.
      This is DISABLED by default as the Computer Object Cleanup Stream takes care of this in a more
      configurable method.

    - Delete unneeded update files
      The wizard will delete all update files that are not needed by updates or by downstream servers.

    - Decline expired updates
      The wizard will decline all updates that have been expired by Microsoft.

    - Decline superseded updates
      The wizard will decline all updates that meet all the following criteria:
          The superseded update is not mandatory
          The superseded update has been on the server for thirty days or more
          The superseded update is not currently reported as needed by any client
          The superseded update has not been explicitly deployed to a computer group for ninety days or more
          The superseding update must be approved for install to a computer group

I recommend that this be done daily. When using -FirstRun, all of the script's streams perform compression and
removal tasks prior to the SCW being run. Therefore, with the exception of DiskSpaceFreed, all of the other
fields of the SCW will return 0 when using -FirstRun.

You can use -WSUSServerCleanupWizard to run this manually from the command-line.

WSUSClean Application Pool Memory Configuration Stream
-----------------------------------------------------
Why does the WSUS Application pool crash and how can we fix it? The WSUS Application pool has a
"private memory limit" setting that is configured by default to a low number based on RAM. The
Application pool crashes because it can't keep up and the limit is reached. So why couldn't the WSUS
Application pool keep up? This has to do with the larger number of updates in the Update Catalog
(database) which continues to grow over time. WSUS does not handle an excessive number of updates well
and as as the number increases, the load on the application pool increases causing it to slowly run out
of memory until the limit is hit and WSUS crashes. I've seen it start having issues above the low
number of 10,000 updates and above the high number of 100,000 updates. The number of updates can in
part be due to obsolete updates that remain in the database and it varies in every system and
implementation. In order to help alleviate this, we can increase the memory on the WSUS Application Pool.

I recommend that this be done manually, only if necessary, by the command-line.

-DisplayApplicationPoolMemory to display the current application pool memory.
-SetApplicationPoolMemory <number in MB> to set the private memory limit by the number specified.

WSUSClean Dirty Database Check Stream
-----------------------------------------------------

From a similar phrase from the movie 'Sleeping With Other People', I coined this stream the
Dirty Database Check. This stream will run a SQL Query that originally came from Microsoft but has been
expanded by me to include all future upgrades of Windows 10. This SQL query checks to see if your
database is 'in a bad state' which is Microsoft's wording but mine sounds a whole lot more fun :)

In addition to checking to see if you have a dirty database, it will fully fix your database
automatically if it is found to be dirty. This again follows Microsoft's methods, but expanded
by me to include all future upgrades of Windows 10.

If your upgrades for Windows 10 are not installing properly and have been approved on your WSUS
server, run this check to see if you have a dirty database and subsequently fix it.

I recommend that this be done manually from the command-line, if you suspect that you may have a
dirty database.

You can use -DirtyDatabaseCheck to run this manually from the command-line.

.NOTES
Name: Clean-WSUS
Author: Some guy who's an asshole now
Website: http://www.WSUSClean.org
Donations Accepted: http://www.WSUSClean.org/clean-wsus/donate.html

This script has been tested on Server 2008 SP2, Server 2008 R2, Server 2012, and Server 2012 R2. This script should run
fine on Server 2016 and others have ran it with success on 2016, but I have not had the ability to test it in production.

################################
#      Version History &       #
#        Release Notes         #
################################

Previous Version History - http://www.WSUSClean.org/clean-wsus/release-notes.html

  Version 3.1 to 3.2
 - Bug Fix: Dirty Database Fix SQL Script to 1.1 - Added use SUSDB.
 - Added EULA.

.EXAMPLE
Clean-WSUS -FirstRun
Description: Run the routines that are recommended for running this script for the first time.

.EXAMPLE
Clean-WSUS -InstallTask
Description: Install the Scheduled task to run this script at 8AM daily with the -ScheduledRun switch.

.EXAMPLE
Clean-WSUS -HelpMe
Description: Run the HelpMe stream to create a transcript of the session and provide troubleshooting information in a log file.

.EXAMPLE
Clean-WSUS -DisplayApplicationPoolMemory
Description: Display the current Private Memory Limit for the WSUS Application Pool

.EXAMPLE
Clean-WSUS -SetApplicationPoolMemory 4096
Description: Set the Private Memory Limit for the WSUS Application Pool to 4096 MB (4GB)

.EXAMPLE
Clean-WSUS -SetApplicationPoolMemory 0
Description: Set the Private Memory Limit for the WSUS Application Pool to 0 MB (Unlimited)

.EXAMPLE
Clean-WSUS -DirtyDatabaseCheck
Description: Checks to see if the WSUS database is in a bad state.

.EXAMPLE
Clean-WSUS -DailyRun
Description: Run the recommended daily routines.

.EXAMPLE
Clean-WSUS -MonthlyRun
Description: Run the recommended monthly routines.

.EXAMPLE
Clean-WSUS -QuarterlyRun
Description: Run the recommended quarterly routines.

.EXAMPLE
Clean-WSUS -ScheduledRun
Description: Run the recommended routines on a schedule having the script take care of all timetables.

.EXAMPLE
Clean-WSUS -RemoveWSUSDriversSQL -SaveReport TXT
Description: Only Remove WSUS Drivers by way of SQL and save the output as TXT to the script's folder named with the date and time of execution.

.EXAMPLE
Clean-WSUS -RemoveWSUSDriversPS -MailReport HTML
Description: Only Remove WSUS Drivers by way of PowerShell and email the output as HTML to the configured parties.

.EXAMPLE
Clean-WSUS -RemoveDeclinedWSUSUpdates -CleanUpWSUSSynchronizationLogs -WSUSDBMaintenance -WSUSServerCleanupWizard -SaveReport HTML -MailReport TXT
Description: Remove Declined WSUS Updates, Clean Up WSUS Synchronization Logs based on the configuration variables, Run the SQL Maintenance, and run the Server Cleanup Wizard (SCW) and output to an HTML file in the scripts folder named with the date and time of execution, and then email the report in plain text to the configured parties.

.EXAMPLE
Clean-WSUS -DeclineMultipleTypesOfUpdates -ComputerObjectCleanup -SaveReport TXT -MailReport HTML
Description: Decline superseded updates, computer object cleanup, save the output as TXT to the script's folder, and email the output as HTML to the configured parties.

.EXAMPLE
Clean-WSUS -RemoveObsoleteUpdates -CompressUpdateRevisions -DeclineMultipleTypesOfUpdates -SaveReport TXT -MailReport HTML
Description: Remove Obsolte Updates, Compress Update Revisions, Decline superseded updates, save the output as TXT to the script's folder, and email the output as HTML to the configured parties.

.LINK
http://www.WSUSClean.org
http://community.spiceworks.com/scripts/show/2998-WSUSClean-wsus-cleanup
http://www.WSUSClean.org/clean-wsus/donate.html
#>

################################
#    Script Setup Parameters   #
#                              #
#  DO NOT EDIT!!! SCROLL DOWN  #
#    TO FIND THE VARIABLES     #
#           TO EDIT            #
################################
[CmdletBinding()]
param (
    # Run the routines that are recommended for running this script for the first time.
    [Switch]$FirstRun,
    # Run the troubleshooting HelpMe stream to copy and paste for getting support.
    [Switch]$HelpMe,
    # Run a check on the SUSDB Database to see if you have a bad state (a dirty database).
    [switch]$DirtyDatabaseCheck,
    # Display the Application Pool Memory Limit
    [switch]$DisplayApplicationPoolMemory,
    # Set the Application Pool Memory Limit.
    [ValidateRange(0,[int]::MaxValue)]
    [Int16]$SetApplicationPoolMemory=-1,
    # Run the recommended daily routines.
    [Switch]$DailyRun,
    # Run the recommended monthly routines.
    [Switch]$MonthlyRun,
    # Run the recommended quarterly routines.
    [Switch]$QuarterlyRun,
    # Run the recommended routines on a schedule having the script take care of all timetables.
    [Switch]$ScheduledRun,
    # Remove WSUS Drivers by way of SQL.
    [Switch]$RemoveWSUSDriversSQL,
    # Remove WSUS Drivers by way of PowerShell.
    [Switch]$RemoveWSUSDriversPS,
    # Compress Update Revisions by way of SQL.
    [Switch]$CompressUpdateRevisions,
    # Remove Obsolete Updates by way of SQL.
    [Switch]$RemoveObsoleteUpdates,
    # Remove Declined WSUS Updates.
    [Switch]$RemoveDeclinedWSUSUpdates,
    # Decline Multiple Types of Updates.
    [Switch]$DeclineMultipleTypesOfUpdates,
    # Clean Up WSUS Synchronization Logs based on the configuration variables.
    [Switch]$CleanUpWSUSSynchronizationLogs,
    # Clean Up WSUS Synchronization Logs based on the configuration variables.
    [Switch]$ComputerObjectCleanup,
    # Run the SQL Maintenance.
    [Switch]$WSUSDBMaintenance,
    # Run the Server Cleanup Wizard (SCW) through PowerShell rather than through a GUI.
    [Switch]$WSUSServerCleanupWizard,
    # Run the Server Cleanup Wizard (SCW) through PowerShell rather than through a GUI.
    [Switch]$WSUSIndexOptimization,
    # Install the Scheduled Task for daily @ 8AM.
    [Switch]$InstallTask,
    # Save the output report to a file named the date and time of execute in the script's folder. TXT or HTML are valid output types.
    [ValidateSet("TXT","HTML")]
    [String]$SaveReport,
    # Email the output report to an email address based on the configuration variables. TXT or HTML are valid output types.
    [ValidateSet("TXT","HTML")]
    [String]$MailReport
    )
Begin {
$WSUSCleanCurrentSystemFunctions = Get-ChildItem function:
$WSUSCleanCurrentSystemVariables = Get-Variable
if (-not $DailyRun -and -not $FirstRun -and -not $MonthlyRun -and -not $QuarterlyRun -and -not $ScheduledRun -and -not $HelpMe -and -not $InstallTask) {
    Write-Verbose "Not using a pre-defined routine"
    if (-not ($DisplayApplicationPoolMemory -or $DirtyDatabaseCheck) -and $SetApplicationPoolMemory -eq '-1') {
        Write-Verbose "Not using a using the Application Pool commands or the InstallTask or DirtyDatabaseCheck"
        if ($SaveReport -eq '' -and $MailReport -eq '') {
            Throw "You must use -SaveReport or -MailReport if you are not going to use the pre-defined routines (-FirstRun, -DailyRun, -MonthlyRun, -QuarterlyRun, -ScheduledRun) or the individual switches -HelpMe -DisplayApplicationPoolMemory and -SetApplicationPoolMemory -DirtyDatabaseCheck."
        } else { Write-Verbose "SaveReport or MailReport have been specified. Continuing on." }
    } else { Write-Verbose "`$DisplayApplicationPoolMemory -or `$SetApplicationPoolMemory -or `$DirtyDatabaseCheck were specified."; Write-Verbose "`$SetApplicationPoolMemory is set to $SetApplicationPoolMemory" }
}
Function Test-RegistryValue {
    param(
        [Alias("PSPath")]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path
        ,
        [Parameter(Position = 1, Mandatory = $true)]
        [String]$Name
        ,
        [Switch]$PassThru
    )
    process {
        if (Test-Path $Path) {
            $Key = Get-Item -LiteralPath $Path
            if ($Key.GetValue($Name, $null) -ne $null) {
                if ($PassThru) {
                    Get-ItemProperty $Path $Name
                } else {
                    $true
                }
            } else {
                $false
            }
        } else {
            $false
        }
    }
}
if ($HelpMe -eq $True) { $WSUSCleanOldVerbose = $VerbosePreference; $VerbosePreference = "continue"; Start-Transcript -Path "$(get-date -f "yyyy.MM.dd-HH.mm.ss")-HelpMe.txt" }

#region Configuration Variables
################################
#    Configuration Variables   #
#     Simple Configuration     #
################################

################################
#  Mail Report Setup Variables #
################################

# From: address for email notifications (it doesn't have to be a real email address, but if you're sending through Gmail it must be
# your Gmail address). Example: 'WSUS@domain.com' or 'email@gmail.com'
[string]$WSUSCleanMailReportEmailFromAddress = 'youremail@email.com'

# To: address for email notifications. Example: 'firstname.lastname@domain.com'
[string]$WSUSCleanMailReportEmailToAddress = 'alertsemail@email.com'

# Subject: of the results email
[string]$WSUSCleanMailReportEmailSubject = 'WSUS Cleanup Results'

# Enter your SMTP server name. Example: 'mailserver.domain.local' or 'mail.domain.com' or 'smtp.gmail.com'
# Note Gmail Settings: smtp.gmail.com Port:587 SSL:Enabled User:user@gmail.com Password (if you use 2FA, make an app password).
[string]$WSUSCleanMailReportSMTPServer = 'smtp.outlook.com'

# Enter your SMTP port number. Example: '25' or '465' (Usually for SSL) or '587' or '1025'
[int32]$WSUSCleanMailReportSMTPPort = '587'

# Do you want to enable SSL communication for your SMTP Server
[boolean]$WSUSCleanMailReportSMTPServerEnableSSL = $True

# Do you need to authenticate to the server? If not, leave blank. Note: if your password includes an apostrophe, use 2 apostrophes so that one escapes the other. eg. 'that''s how'
[string]$WSUSCleanMailReportSMTPServerUsername = 'youremail@email.com'
[string]$WSUSCleanMailReportSMTPServerPassword = ''

################################
#    Configuration Variables   #
#    Advanced Configuration    #
################################

################################
#  Mail Report or Save Report  #
################################

# Do you want to enable the Mail Report for every run?
[boolean]$WSUSCleanMailReport = $True

# Do you want the mailed report to be in HTML or plain text? (Valid options are 'HTML' or 'TXT')
[string]$WSUSCleanMailReportType = 'HTML'

# Do you want to enable the save report for every run? (-FirstRun will save the report regardless)
[boolean]$WSUSCleanSaveReport = $False

# Do you want the saved report to be outputted in HTML or plain text? (Valid options are 'HTML' or 'TXT')
[string]$WSUSCleanSaveReportType = 'TXT'

################################
#    Decline Multiple Types    #
#     of Updates Variables     #
################################

$WSUSCleanDeclineMultipleTypesOfUpdatesList = @{
'Superseded' = $True #remove superseded updates.
'Expired' = $True #remove updates that have been pulled by Microsoft.
'Preview' = $True #remove preview updates.
'Itanium' = $True #remove updates for Itanium computers.
'LanguagePacks' = $False #remove language packs.
'IE7' = $False #remove updates for old versions of IE (IE7).
'IE8' = $False #remove updates for old versions of IE (IE8).
'IE9' = $False #remove updates for old versions of IE (IE9).
'IE10' = $False #remove updates for old versions of IE (IE10).
'Beta' = $True #Beta products and beta updates.
'Embedded' = $False #Embedded version of Windows.
'NonEnglishUpdates' = $False #some non-English updates are not filtered by WSUS language filtering.
'ComputerUpdates32bit' = $False #remove updates for 32-bit computers.
'WinXP' = $False #remove Windows XP updates.
}

################################
#   Computer Object Cleanup    #
#          Variables           #
################################

# Do you want to remove the computer objects from WSUS that have not synchronized in days?
# This is good to keep your WSUS clean of previously removed computers.
[boolean]$WSUSCleanComputerObjectCleanup = $True

# If the above is set to $True, how many days of no synchronization do you want to remove
# computer objects from the WSUS Server? Set this to 0 to remove all computer objects.
[int]$WSUSCleanComputerObjectCleanupSearchDays = '30'

################################
#  WSUS Server Cleanup Wizard  #
#          Parameters          #
#    Set to $True or $False    #
################################

# Decline updates that have not been approved for 30 days or more, are not currently needed by any clients, and are superseded by an approved update.
[boolean]$WSUSCleanSCWSupersededUpdatesDeclined = $True

# Decline updates that aren't approved and have been expired my Microsoft.
[boolean]$WSUSCleanSCWExpiredUpdatesDeclined = $True

# Delete updates that are expired and have not been approved for 30 days or more.
[boolean]$WSUSCleanSCWObsoleteUpdatesDeleted = $True

# Delete older update revisions that have not been approved for 30 days or more.
[boolean]$WSUSCleanSCWUpdatesCompressed = $True

# Delete computers that have not contacted the server in 30 days or more. Default: $False
# This is taken care of by the Computer Object Cleanup Stream
[boolean]$WSUSCleanSCWObsoleteComputersDeleted = $False

# Delete update files that aren't needed by updates or downstream servers.
[boolean]$WSUSCleanSCWUnneededContentFiles = $True

################################
#   Scheduled Run Variables    #
################################

# On what day do you wish to run the MonthlyRun and QuarterlyRun Stream? I recommend on the 1st-7th of the month.
# This will give enough time for you to approve (if you approve manually) and your computers to receive the
# superseding updates after patch Tuesday (second Tuesday of the month).
# (Valid days are 1-31. February, April, June, September, and November have logic to set to the last day
# of the month if this is set to a number greater than the amount of days in that month, including leap years.)
[int]$WSUSCleanScheduledRunStreamsDay = '1'

# What months would you like to run the QuarterlyRun Stream?
# (Valid months are 1-12, comma separated for multiple months)
[string]$WSUSCleanScheduledRunQuarterlyMonths = '1,4,7,10'

# What time daily do you want to run the script using the scheduled task?
[string]$WSUSCleanScheduledTaskTime = '8:00am'

################################
#        Clean Up WSUS         #
#     Synchronization Logs     #
#           Variables          #
################################

# Clean up the synchronization logs older than a consistency.

# (Valid consistency number are whole numbers.)
[int]$WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyNumber = '14'

# Valid consistency time are 'Day' or 'Month'
[String]$WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyTime = 'Day'

# Or remove all synchronization logs each time
[boolean]$WSUSCleanCleanUpWSUSSynchronizationLogsAll = $False

################################
#     Remove WSUS Drivers      #
#          Variables           #
################################

# Remove WSUS Drivers on -FirstRun
[boolean]$WSUSCleanRemoveWSUSDriversInFirstRun = $True

# Remove WSUS Drivers on -ScheduledRun or -QuaterlyRun
[boolean]$WSUSCleanRemoveWSUSDriversInRoutines = $True


################################
#     SQL Server Variable      #
################################

# The SQL Server Variable is detected automatically whether you are using the Windows Internal Database, a SQL
# Express instance on the same server or remote server, or a full SQL version on the same server or remote server.

# If you are using a Remote SQL connection, you will need to set the Scheduled Task to use the NETWORK SERVICE
# account as the user that runs the script. This will run the script with the computer object's security context
# when accessing resources over the network. As such, the SQL Server will need the computer account added (in
# the format of: DOMAIN\COMPUTER$) with the appropriate permissions (db_dlladmin or db_owner) for the SUSDB
# database. This is the recommended way of doing it.

# An alternative way of doing it would be to run the Scheduled Task as a user account that already has the
# appropriate permissions, saving credentials so that it can pass them through to the SQL Server.

# ONLY uncomment and fill out if you've received explicit instructions from me for support.
#[string]$WSUSCleanSQLServer = 'THIS LINE SHOULD ONLY BE CHANGED WITH EXPLICIT INSTRUCTIONS FROM SUPPORT!'

################################
#     WSUS Setup Variables     #
#  This section auto-detects   #
#      and shouldn't need      #
#        to be modified        #
################################

# FQDN of the WSUS server. Example: 'server.domain.local'
# WSUS does not play well with Aliases or CNAMEs and requires using the FQDN or the HostName
[string]$WSUSCleanWSUSServer = "$((Get-WmiObject win32_computersystem).DNSHostName)" + $(if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain -eq 'True') { ".$((Get-WmiObject win32_computersystem).Domain)" } )

# Use secure connection: $True or $False
[boolean]$WSUSCleanWSUSServerUseSecureConnection = if ($(Test-RegistryValue "HKLM:\Software\Microsoft\Update Services\Server\Setup" "UsingSSL") -eq $True) { if ((Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Update Services\Server\Setup' -Name 'UsingSSL' | Select-Object -ExpandProperty 'UsingSSL') -eq '1') { $True } else { $False } } else { $False }

# What port number are you using for WSUS? Example: '80' or '443' if on Server 2008 or '8530' or '8531' if on Server 2012+
[int32]$WSUSCleanWSUSServerPortNumber = Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Update Services\Server\Setup' -Name 'PortNumber' | Select-Object -ExpandProperty 'PortNumber'

################################
#  Install the Scheduled Task  #
#  This section should be left #
#            alone.            #
################################

<#
This script is meant to be run daily. It is not just an ad-hock WSUS cleaning tool but rather
it's a daily maintenance tool. -FirstRun does NOT run all the routines on purpose, and uses certain
switches that SHOULD NOT be used consistently. If you choose to ignore this and switch the
$WSUSCleanInstallScheduledTask variable to $False, please know that you can encounter problems with
WSUS in the future that you can't explain. One should not blame Microsoft for messing up WSUS or not
being able to make a product that works (like so many others have done), but rather blame themselves
for not running the appropriate WSUS Maintenance routines (declining superseded updates, running the
WSUS maintenance SQL script, running the server cleanup wizard, etc), to keep WSUS running smoothly.

For those enterprise environments or environments where you want more control over when this script
runs its streams, I've included the different switches (DailyRun, MonthlyRun, and QuarterlyRun) to be
used on the appropriate schedules. Do not mistake these options as assuming this script should be run
only when you feel it is necessary. For these environments, please set the $WSUSCleanInstallScheduledTask
variable to $False and then manually create at least 3 scheduled tasks to run the -DailyRun,
-MonthlyRun, and -QuarterlyRun switches following the template of -InstallTask's schedule.
#>

# Install the ScheduledTask to Task Scheduler. (Default: $True)
[boolean]$Script:WSUSCleanInstallScheduledTask = $True

################################
# Do not edit below this line  #
################################
}
#endregion

Process {
$WSUSCleanScriptTime = Get-Date
$WSUSCleanWSUSServer = $WSUSCleanWSUSServer.ToLower()
Write-verbose "Set the script's current working directory path"
$WSUSCleanScriptPath = Split-Path $script:MyInvocation.MyCommand.Path
Write-Verbose "`$WSUSCleanScriptPath = $WSUSCleanScriptPath"

#region Test Elevation
function Test-Administrator
{
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $CurrentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
Write-Verbose "Testing to see if you are running this from an Elevated PowerShell Prompt."
if ((Test-Administrator) -ne $True -and ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name -ne 'NT AUTHORITY\SYSTEM')) {
    Throw "ERROR: You must run this from an Elevated PowerShell Prompt on each WSUS Server in your environment. If this is done through scheduled tasks, you must check the box `"Run with the highest privileges`""
}
else {
    Write-Verbose "Done. You are running this from an Elevated PowerShell Prompt"
}
#endregion Test Elevation

#region Test-IfBlocked
function Test-IfBlocked {
    if ($(Get-Item $($script:MyInvocation.MyCommand.Path) -Stream "Zone.Identifier" -ErrorAction SilentlyContinue) -eq $null) {
        Write-Verbose "Zone.Identifier not found. The file is already unblocked"
    } else {
        Write-Verbose "Zone.Identifier was found. Unblocking File"
        Unblock-File -Path $($script:MyInvocation.MyCommand.Path)
    }
}
Test-IfBlocked
#endregion Test-IfBlocked

if ($HelpMe -eq $True) {
    $Script:HelpMeHeader = @"
=============================
  Clean-WSUS HelpMe Stream
=============================

This is the HelpMe Section for troubleshooting
Please provide this information to get support



"@
    $Script:WSUSCleanScriptVersion = "3.2"
    $Script:HelpMeHeader
    Write-Output 'Starting the connection to the SQL database and WSUS services. Please wait...'
} else {
    Write-Output 'Starting the connection to the SQL database and WSUS services. Please wait...'
}

#region Test SQLConnection
function Test-SQLConnection
{
    param (
        [parameter(Mandatory = $true)][string] $ServerInstance,
        [parameter(Mandatory = $false)][int] $TimeOut = 1
    )

    $SqlConnectionResult = $false

    try
    {
        $SqlCatalog = "SUSDB"
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = "Server = $ServerInstance; Database = $SqlCatalog; Integrated Security = True; Connection Timeout=$TimeOut"
        $TimeOutVerbage = if ($TimeOut -gt "1") { "seconds" } else { "second" }
        Write-Verbose "Initiating SQL Connection Testing to `'$ServerInstance'` with a timeout of $TimeOut $TimeOutVerbage"
        $SqlConnection.Open()
        Write-Verbose "Connected. Setting `$SqlConnectionResult to $($SqlConnection.State -eq "Open")"
        $SqlConnectionResult = $SqlConnection.State -eq "Open"
    }

    catch
    {
        Write-Output "Connection Failed."
    }

    finally
    {
        $SqlConnection.Close()
    }

    return $SqlConnectionResult
}

if ([string]::isnullorempty($WSUSCleanSQLServer)) {
    Write-Verbose '$WSUSCleanSQLServer has not been specified. Starting autodetection for SQL Instance'
    [string]$WSUSCleanWID2008 = 'np:\\.\pipe\MSSQL$MICROSOFT##SSEE\sql\query'
    [string]$WSUSCleanWID2012Plus = 'np:\\.\pipe\MICROSOFT##WID\tsql\query'
    $WSUSCleanSQLServerName = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Update Services\Server\Setup" -Name "SqlServerName" | Select-Object -ExpandProperty "SqlServerName"
    #$WSUSCleanSQLServerName = "$((Get-WmiObject win32_computersystem).DNSHostName)\MICROSOFT##SSEE" #2008 Testing
    #$WSUSCleanSQLServerName = "$((Get-WmiObject win32_computersystem).DNSHostName)\SQLEXPRESS" #SQLEXPRESS instance Testing
    #$WSUSCleanSQLServerName = "$((Get-WmiObject win32_computersystem).DNSHostName)" #SQL Standard default instance testing
    #$WSUSCleanSQLServerName = "$((Get-WmiObject win32_computersystem).DNSHostName)\NamedWSUSInstance" #SQL Other Named Instance testing
    #$WSUSCleanSQLServerName = "REMOTESERVER" #SQL Remote Server testing
    Write-Verbose "Autodetected `$WSUSCleanSQLServerName as $WSUSCleanSQLServerName"
    if ($WSUSCleanSQLServerName -eq 'MICROSOFT##WID') {
        Write-Verbose 'Setting $WSUSCleanSQLServer for Server 2012+ Windows Internal Database.'
        $WSUSCleanSQLServer = $WSUSCleanWID2012Plus
    } elseif ($WSUSCleanSQLServerName -eq "$((Get-WmiObject win32_computersystem).DNSHostName)\MICROSOFT##SSEE") {
        Write-Verbose 'Setting $WSUSCleanSQLServer for Server 2008 & 2008 R2 Windows Internal Database.'
        $WSUSCleanSQLServer = $WSUSCleanWID2008
    } elseif ($WSUSCleanSQLServerName -eq "$((Get-WmiObject win32_computersystem).DNSHostName)\SQLEXPRESS") {
        Write-Verbose "Setting `$WSUSCleanSQLServer for SQLEXPRESS Instance on the local server - `'$WSUSCleanSQLServerName'."
        $WSUSCleanSQLServer = $WSUSCleanSQLServerName
    } elseif ($WSUSCleanSQLServerName -eq "$((Get-WmiObject win32_computersystem).DNSHostName)") {
        Write-Verbose "Setting `$WSUSCleanSQLServer for SQL Default Instance on the local server - `'$WSUSCleanSQLServerName`'."
        $WSUSCleanSQLServer = $WSUSCleanSQLServerName
    } else {
        Write-Verbose "Setting `$WSUSCleanSQLServer to the remote SQL Instance of: `'$WSUSCleanSQLServerName`'."
        $WSUSCleanSQLServer = $WSUSCleanSQLServerName
        $WSUSCleanSQLServerIsRemote = $True
    }
} else {
    Write-Verbose "You've specified the `$WSUSCleanSQLServer variable as `'$WSUSCleanSQLServer`'."
}
Write-Verbose "Now test that there is a SUSDB database on `'$WSUSCleanSQLServer`' and that we can connect to it."
if ((Test-SQLConnection $WSUSCleanSQLServer 60) -eq $true) {
    Write-Verbose "SQL Server test succeeded. Continuing on."
} else {
    if ($HelpMe -ne $True) {
        #Terminate the script erroring out with a reason.
        #Throw "I've tested the server `'$WSUSCleanSQLServer`' from the configuration but can't connect to that SQL Server Instance. Please check the spelling again. Don't forget to specify the SQL Instance if there is one."
    }
    else {
        Write-Output "I can't connect to the SQL server `'$WSUSCleanSQLServer`', and you've asked for help. Connecting to the WSUS Server to get troubleshooting information."
    }
}
#Create the connection command variable.
$WSUSCleanSQLConnectCommand = "sqlcmd -S $WSUSCleanSQLServer"
#endregion Test SQLConnection

#region Connect to the WSUS Server
function Connect-WSUSServer {
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory = $True)]
        [Alias("Server")]
        [string]$WSUSServer,

        [Parameter(Position=1, Mandatory = $True)]
        [Alias("Port")]
        [int]$WSUSPort,

        [Parameter(Position=2, Mandatory = $True)]
        [Alias("SSL")]
        [boolean]$WSUSEnableSSL
    )
    Write-Verbose "Load .NET assembly"
    [void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration");

    Write-Verbose "Connect to WSUS Server: $WSUSServer"
    $Script:WSUSAdminProxy     = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($WSUSServer,$WSUSEnableSSL,$WSUSPort);
    If ($? -eq $False) {
        if ($HelpMe -ne $True) {
            Throw "ERROR Connecting to the WSUS Server: $WSUSServer. Please check your settings and try again."
        }
        else {
            Write-Output "ERROR Connecting to the WSUS Server: $WSUSServer and you've asked for help. Getting troubleshooting information."
        }
    } else {
            $Script:WSUSCleanConnectedTime = Get-Date
            $Script:WSUSCleanConnectedTXT = "Connected to the WSUS server $WSUSCleanWSUSServer @ $($WSUSCleanConnectedTime.ToString(`"yyyy.MM.dd hh:mm:ss tt zzz`"))`r`n`r`n"
            $Script:WSUSCleanConnectedHTML = "<i>Connected to the WSUS server $WSUSCleanWSUSServer @ $($WSUSCleanConnectedTime.ToString(`"yyyy.MM.dd hh:mm:ss tt zzz`"))</i>`r`n`r`n"
    	    Write-Output "Connected to the WSUS server $WSUSCleanWSUSServer"
    }
}
Write-Verbose 'Do we really need to connect to the WSUS Server? If we do, connect.'
if ((($InstallTask -or $DisplayApplicationPoolMemory -or $WSUSIndexOptimization) -eq $False) -and $SetApplicationPoolMemory -eq '-1') {
    Write-Verbose 'We have a reason to connect. Connecting...'
    Connect-WSUSServer -Server $WSUSCleanWSUSServer -Port $WSUSCleanWSUSServerPortNumber -SSL $WSUSCleanWSUSServerUseSecureConnection
    $WSUSCleanWSUSServerAdminProxy = $Script:WSUSAdminProxy
}
else {
    Write-Verbose 'We do not have a reason to connect. Continuing on without connecting to the WSUS API'
    Write-Verbose "`$SetApplicationPoolMemory is set to $SetApplicationPoolMemory"
}
#endregion Connect to the WSUS Server

#region Get-DiskFree Function
################################
#         Get-DiskFree         #
################################

function Get-DiskFree
# Taken from http://binarynature.blogspot.ca/2010/04/powershell-version-of-df-command.html
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias('hostname')]
        [Alias('cn')]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter(Position=1,
                   Mandatory=$false)]
        [Alias('runas')]
        [System.Management.Automation.Credential()]$Credential =
        [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Position=2)]
        [switch]$Format
    )

    BEGIN
    {
        function Format-HumanReadable
        {
            param ($size)
            switch ($size)
            {
                {$_ -ge 1PB}{"{0:#.#'P'}" -f ($size / 1PB); break}
                {$_ -ge 1TB}{"{0:#.#'T'}" -f ($size / 1TB); break}
                {$_ -ge 1GB}{"{0:#.#'G'}" -f ($size / 1GB); break}
                {$_ -ge 1MB}{"{0:#.#'M'}" -f ($size / 1MB); break}
                {$_ -ge 1KB}{"{0:#'K'}" -f ($size / 1KB); break}
                default {"{0}" -f ($size) + "B"}
            }
        }
        $wmiq = 'SELECT * FROM Win32_LogicalDisk WHERE Size != Null AND DriveType >= 2'
    }

    PROCESS
    {
        foreach ($computer in $ComputerName)
        {
            try
            {
                if ($computer -eq $env:COMPUTERNAME)
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -ErrorAction Stop
                }
                else
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -Credential $Credential `
                             -ErrorAction Stop
                }

                if ($Format)
                {
                    # Create array for $disk objects and then populate
                    $diskarray = @()
                    $disks | ForEach-Object { $diskarray += $_ }

                    $diskarray | Select-Object @{n='Name';e={$_.SystemName}},
                        @{n='Vol';e={$_.DeviceID}},
                        @{n='Size';e={Format-HumanReadable $_.Size}},
                        @{n='Used';e={Format-HumanReadable `
                        (($_.Size)-($_.FreeSpace))}},
                        @{n='Avail';e={Format-HumanReadable $_.FreeSpace}},
                        @{n='Use%';e={[int](((($_.Size)-($_.FreeSpace))`
                        /($_.Size) * 100))}},
                        @{n='FS';e={$_.FileSystem}},
                        @{n='Type';e={$_.Description}}
                }
                else
                {
                    foreach ($disk in $disks)
                    {
                        $diskprops = @{'Volume'=$disk.DeviceID;
                                   'Size'=$disk.Size;
                                   'Used'=($disk.Size - $disk.FreeSpace);
                                   'Available'=$disk.FreeSpace;
                                   'FileSystem'=$disk.FileSystem;
                                   'Type'=$disk.Description
                                   'Computer'=$disk.SystemName;}

                        # Create custom PS object and apply type
                        $diskobj = New-Object -TypeName PSObject `
                                   -Property $diskprops
                        $diskobj.PSObject.TypeNames.Insert(0,'BinaryNature.DiskFree')

                        Write-Output $diskobj
                    }
                }
            }
            catch
            {
                # Check for common DCOM errors and display "friendly" output
                switch ($_)
                {
                    { $_.Exception.ErrorCode -eq 0x800706ba } `
                        { $err = 'Unavailable (Host Offline or Firewall)';
                            break; }
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' } `
                        { $err = 'Access denied (Check User Permissions)';
                            break; }
                    default { $err = $_.Exception.Message }
                }
                Write-Warning "$computer - $err"
            }
        }
    }

    END {}
}
#endregion Get-DiskFree Function

#region Setup The Header
################################
#       Setup the Header       #
################################

function CreateWSUSCleanHeader {
$Script:WSUSCleanBodyHeaderTXT = @"
################################
#                              #
#       WSUSClean Clean-WSUS       #
#         Version 3.2          #
#                              #
#   The last WSUS Script you   #
#        will ever need!       #
#                              #
################################


"@
$Script:WSUSCleanBodyHeaderHTML = @"
    <table style="height: 0px; width: 0px;" border="0">
	    <tbody>
		    <tr>
			    <td colspan="3">
				    <span
						    style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span>
			    </td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;">&nbsp;</td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">WSUSClean Clean-WSUS</span></td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">Version 3.2</span></td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td>&nbsp;</td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">The last WSUS Script you</span></td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">will ever need!</span></td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td style="text-align: left;">#</td>
			    <td>&nbsp;</td>
			    <td style="text-align: right;">#</td>
		    </tr>
		    <tr>
			    <td colspan="3"><span style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span></td>
		    </tr>
	    </tbody>
    </table>
"@
}
#endregion Setup The Header

#region Setup The Footer
################################
#       Setup the Footer       #
################################

function CreateWSUSCleanFooter {
$Script:WSUSCleanBodyFooterTXT = @"

################################
#    End of the WSUS Cleanup   #
################################
#                              #
#         WSUS Cleanup        #
#     http://www.WSUSClean.org     #
#      Donations Accepted      #
#                              #
#   Latest version available   #
#        from Spiceworks       #
#                              #
################################

http://community.spiceworks.com/scripts/show/2998-WSUSClean-clean-wsus
Donations Accepted: http://www.WSUSClean.org/clean-wsus/donate.html
"@
$Script:WSUSCleanBodyFooterHTML = @"
    <table style="height: 0px; width: 0px;" border="0">
      <tbody>
        <tr>
          <td colspan="3"><span style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span></td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">End of the WSUS Cleanup</span></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td colspan="3" rowspan="1"><span style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span></td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;">&nbsp;</td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">WSUS Cleanup</span></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">http://www.WSUSClean.org</span></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><a href="http://www.WSUSClean.org/clean-wsus/donate.html"><span style="font-family: tahoma,arial,helvetica,sans-serif;">Donations Accepted</span></a></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td>&nbsp;</td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><span style="font-family: tahoma,arial,helvetica,sans-serif;">Latest version available</span></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td style="text-align: center;"><a href="http://community.spiceworks.com/scripts/show/2998-WSUSClean-clean-wsus"><span style="font-family: tahoma,arial,helvetica,sans-serif;">from Spiceworks</span></a></td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td style="text-align: left;">#</td>
          <td>&nbsp;</td>
          <td style="text-align: right;">#</td>
        </tr>
        <tr>
          <td colspan="3"><span style="font-family: tahoma,arial,helvetica,sans-serif;">################################</span></td>
        </tr>
      </tbody>
    </table>
"@
}
#endregion Setup The Footer

#region Show-My Functions
################################
#   Show-My Functions Stream   #
################################

function Show-MyFunctions { Get-ChildItem function: | Where-Object { $WSUSCleanCurrentSystemFunctions -notcontains $_ } | Format-Table -AutoSize -Property CommandType,Name }
function Show-MyVariables { Get-Variable | Where-Object { $WSUSCleanCurrentSystemVariables -notcontains $_ } | Format-Table }
#endregion Show-My Functions

#region Install-Task Function
################################
#  Install-Task Configuration  #
################################

Function Install-Task {
    Write-Verbose "Enter Install-Task Function"
    $DateNow = Get-Date
    Write-Verbose "`$DateNow is $DateNow"
    if ($Script:WSUSCleanInstallScheduledTask -eq $True -or $InstallTask -eq $True) {
        $PowerShellMajorVersion = $($PSVersionTable.PSVersion.Major)
        $Version = @{}
        $Version.Add("Major", ((Get-CimInstance Win32_OperatingSystem).Version).Split(".")[0])
        $Version.Add("Minor", ((Get-CimInstance Win32_OperatingSystem).Version).Split(".")[1])
        #$Version.Add("Major", "5") # Comment above 2 lines and then uncomment for testing
        #$Version.Add("Minor", "3") # Uncomment for testing
        if ([int]$Version.Get_Item("Major") -ge "7" -or ([int]$Version.Get_Item("Major") -ge "6" -and [int]$Version.Get_Item("Minor") -ge "2")) {
            Write-Verbose "YES - OS Version $([int]$Version.Get_Item("Major")).$([int]$Version.Get_Item("Minor"))"
            $Windows = [PSCustomObject]@{
                Caption = (Get-WmiObject -Class Win32_OperatingSystem).Caption
                Version = [Environment]::OSVersion.Version
            }
            if ($Windows.Version.Major -gt "6") { Write-Verbose "$($Windows.Caption) - Use Win8 Compatibility"; $Compatibility = "Win8" }
            if ($Windows.Version.Major -ge "6" -and $Windows.Version.Minor -ge "2" ) { Write-Verbose "$($Windows.Caption) - Use Win8 Compatibility"; $Compatibility = "Win8" }
            if ($Windows.Version.Major -ge "6" -and $Windows.Version.Minor -eq "1" ) { Write-Verbose "$($Windows.Caption) - Use Win7 Compatibility"; $Compatibility = "Win7" }
            if ($Windows.Version.Major -ge "6" -and $Windows.Version.Minor -eq "0" ) { Write-Verbose "$($Windows.Caption) - Use Vista Compatibility"; $Compatibility = "Vista" }

            $Trigger = New-ScheduledTaskTrigger -At $WSUSCleanScheduledTaskTime -Daily #Trigger the task daily at $WSUSCleanScheduledTaskTime
            $User = "$env:USERDOMAIN\$env:USERNAME"
            if ($WSUSCleanSQLServerIsRemote -eq $True) { $Principal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest } else { $Principal = New-ScheduledTaskPrincipal -UserID "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U -RunLevel Highest }
            $TaskName = "WSUSClean"
            $Description = "This task will run the WSUSClean Clean-WSUS script with the -ScheduledRun parameter which takes care of everything for you according to my recommendations."
            if ($Script:MyInvocation.MyCommand.Path.Contains(" ") -eq $True) {
                $Action = New-ScheduledTaskAction -Execute "$((Get-Command powershell.exe).Definition)" -Argument "-ExecutionPolicy Bypass -Command `"& `"`"$($script:MyInvocation.MyCommand.Path)`"`"`" -ScheduledRun"
            } else {
                $Action = New-ScheduledTaskAction -Execute "$((Get-Command powershell.exe).Definition)" -Argument "-ExecutionPolicy Bypass `"$($script:MyInvocation.MyCommand.Path) -ScheduledRun`""
            }
            $Settings = New-ScheduledTaskSettingsSet -Compatibility $Compatibility
            Write-Verbose "Register the Scheduled task."
            $Script:WSUSCleanInstallTaskOutput = Register-ScheduledTask -TaskName $TaskName -Description $Description -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Force
            if ($WSUSCleanSQLServerIsRemote -eq $True) {
                Write-Verbose "As the SQL Server is remote, we need to give the computer name account db_owner access into SQL"
                $WSUSCleanSQLServerIsRemoteALERT = @"
!!! SECURITY AWARENESS ALERT !!! Your SQL Server is a REMOTE SQL server. In order to run a scheduled task on a remote SQL Server,
the computer object's active directory account [$([Environment]::UserDomainName)\$([Environment]::MachineName)`$] needs to have the db_owner permission on the SUSDB
database on $WSUSCleanSQLServer. Since WSUS is already installed and running, this account is already setup in the SQL Server and already
granted rights inside of the SUSDB database, so all we need to do is add the account to the db_owner role. Unfortunately it
must be db_owner and not the db_ddladmin role.
"@
                $WSUSCleanSQLServerIsRemoteScript = @"
USE [SUSDB]
GO
ALTER ROLE [db_owner] ADD MEMBER [$([Environment]::UserDomainName)\$([Environment]::MachineName)`$];
PRINT 'Successfully added [$([Environment]::UserDomainName)\$([Environment]::MachineName)`$] to the db_owner role of the SUSDB database on $WSUSCleanSQLServer.'
"@
                Write-Verbose "Create a file with the content of the SQLServerIsRemote Script above in the same working directory as this PowerShell script is running."
                $WSUSCleanSQLServerIsRemoteScriptFile = "$WSUSCleanScriptPath\WSUSCleanSQLServerIsRemoteScript.sql"
                $WSUSCleanSQLServerIsRemoteScript | Out-File "$WSUSCleanSQLServerIsRemoteScriptFile"

                # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
                $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
                Write-Verbose "Execute the SQL Script and store the results in a variable."
                $WSUSCleanSQLServerIsRemoteScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanSQLServerIsRemoteScriptFile`" -I")
                Write-Verbose "`$WSUSCleanSQLServerIsRemoteScriptJob = $WSUSCleanSQLServerIsRemoteScriptJobCommand"
                $WSUSCleanSQLServerIsRemoteScriptJob = Start-Job -ScriptBlock $WSUSCleanSQLServerIsRemoteScriptJobCommand
                Wait-Job $WSUSCleanSQLServerIsRemoteScriptJob
                $WSUSCleanSQLServerIsRemoteScriptJobOutput = Receive-Job $WSUSCleanSQLServerIsRemoteScriptJob
                Remove-Job $WSUSCleanSQLServerIsRemoteScriptJob
                Write-Verbose "Remove the SQL Script file."
                Remove-Item "$WSUSCleanSQLServerIsRemoteScriptFile"
                # Setup variables to store the output to be added at the very end of the script for logging purposes.
                $Script:WSUSCleanSQLServerIsRemoteScriptOutputTXT = $WSUSCleanSQLServerIsRemoteALERT -creplace "$","`r`n`r`n"
                $Script:WSUSCleanSQLServerIsRemoteScriptOutputTXT += $WSUSCleanSQLServerIsRemoteScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n"
            }
        } else {
            Write-Verbose "NO - OS Version $([int]$Version.Get_Item("Major")).$([int]$Version.Get_Item("Minor"))"
            $WSUSCleanManuallyCreateTaskInstructions = @"
You are not using Windows Server 2012 or higher. You will have to manually create the Scheduled Task

To Create a Scheduled Task:

1. Open Task Scheduler and Create a new task (not a basic task)
2. Go to the General Tab:
3. Name: "WSUSClean"
4. Under the section "Security Options" put the dot in "Run whether the user is logged on or not"
5. Check "Do not store password. The task will only have access to local computer resources"
6. Check "Run with highest privileges."
7. Under the section "Configure for" - Choose the OS of the Server (e.g. Server 2012 R2)
8. Go to the Triggers Tab:
9. Click New at the bottom left.
10. Under the section "Settings"
11. Choose Daily. Choose $WSUSCleanScheduledTaskTime
12. Confirm Enabled is checked, Press OK.
13. Go to the Actions Tab:
14. Click New at the bottom left.
15. Action should be "Start a program"
16. The "Program/script" should be set to

        $((Get-Command powershell.exe).Definition)

17. The arguments line should be set to


        $(if ($Script:MyInvocation.MyCommand.Path.Contains(" ") -eq $True) {
                "-ExecutionPolicy Bypass -Command `"& `"`"$($script:MyInvocation.MyCommand.Path)`"`"`" -ScheduledRun"
            } else {
                "-ExecutionPolicy Bypass `"$($script:MyInvocation.MyCommand.Path) -ScheduledRun`""
            })

18. Go to the Settings Tab:
19. Check "Allow task to be run on demand"
20. Click OK
"@
            $WSUSCleanInstallTaskOutput = $WSUSCleanManuallyCreateTaskInstructions
        }
    } else {
        $WSUSCleanInstallTaskOutput = @"
WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!! WARNING!!!

You've chosen to not install the scheduled task that runs -ScheduledRun daily. THIS SCRIPT
IS MEANT TO BE RUN DAILY as it performs daily tasks that should be performed to keep WSUS
running in tip-top running condition. Since you've chosen not to install the scheduled task,
be sure to schedule manually the -DailyRun, -MonthlyRun, and -QuarterlyRun on an appropriate
schedule. Continuously running -FirstRun manually will NOT keep your WSUS maintained
properly as there are specific differences with -FirstRun. -FirstRun also does NOT run
everything on purpose, and does run streams that should NOT be used consistently.
"@
    }
    $FinishedRunning = Get-Date
    Write-Verbose "`$FinishedRunning is $FinishedRunning"
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning
    $Duration = "{0:00}:{1:00}:{2:00}:{3:00}:{4:00}" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds})
    Write-Verbose "WSUSClean Clean-WSUS Scheduled Task Installation Stream Duration: $Duration"
    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    $Script:WSUSCleanInstallTaskOutputTXT += "WSUSClean Clean-WSUS Scheduled Task Installation:`r`n`r`n"
    if ($WSUSCleanInstallTaskOutput.GetType().Name -eq "String") {
        $Script:WSUSCleanInstallTaskOutputTXT += $($WSUSCleanInstallTaskOutput.Trim() -creplace '$?',"" -creplace "$","`r`n`r`n")
        $Script:WSUSCleanInstallTaskOutputTXT += $Script:WSUSCleanSQLServerIsRemoteScriptOutputTXT
        Write-Output ""; Write-Output $WSUSCleanInstallTaskOutput
    } else {
        $Script:WSUSCleanInstallTaskOutputTXT += $($WSUSCleanInstallTaskOutput | Select-Object -Property TaskName,State | Format-List | Out-String).Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n"
        $Script:WSUSCleanInstallTaskOutputTXT += $Script:WSUSCleanSQLServerIsRemoteScriptOutputTXT
        Write-Output $($WSUSCleanInstallTaskOutput | Select-Object -Property TaskName,State | Format-List | Out-String).Trim()
        Write-Output $Script:WSUSCleanSQLServerIsRemoteScriptOutputTXT
    }
    #$Script:WSUSCleanInstallTaskOutputTXT += "`r`nWSUSClean Clean-WSUS Scheduled Task Installation: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanInstallTaskOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Clean-WSUS Scheduled Task Installation:</span></p>`r`n"
    if ($WSUSCleanInstallTaskOutput.GetType().Name -eq "String") {
    #if ($Script:WSUSCleanInstallScheduledTask -eq $False) { $WSUSCleanInstallTaskOutput = $WSUSCleanInstallTaskOutput -creplace '\r\n', " " } (Not sure if I want to use this or not)
        $Script:WSUSCleanInstallTaskOutputHTML += $WSUSCleanInstallTaskOutput -creplace '\r\n', "<br>`r`n" -creplace '^',"<p>" -creplace '$', "</p>`r`n"
    } else {
        $Script:WSUSCleanInstallTaskOutputHTML += $($WSUSCleanInstallTaskOutput| Select-Object TaskName,State | ConvertTo-Html -Fragment -PreContent "<div id='gridtable'>`r`n" -PostContent "</div>`r`n") #.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n"
    }
    #$Script:WSUSCleanInstallTaskOutputHTML += $WSUSCleanInstallTaskOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n"
    #$Script:WSUSCleanInstallTaskOutputHTML += "`r`n<p>WSUSClean Clean-WSUS Scheduled Task Installation: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanInstallTaskOutputTXT
    # $WSUSCleanInstallTaskOutputHTML
}
#endregion Install-Task Function

#region DeclineMultipleTypesOfUpdates Function
################################
#    Decline Multiple Types    #
#      of Updates Stream       #
################################

Write-Verbose "Setup the array variables from the user configuration"

$Superseded = New-Object System.Object
$Superseded | Add-Member -type NoteProperty -name Name -Value "Superseded"
$Superseded | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.Superseded)
$Superseded | Add-Member -type NoteProperty -name Syntax -Value '$_.IsSuperseded -eq $True'

$Expired = New-Object System.Object
$Expired | Add-Member -type NoteProperty -name Name -Value "Expired"
$Expired | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.Expired)
$Expired | Add-Member -type NoteProperty -name Syntax -Value '$_.PublicationState -eq "Expired"'

$Preview = New-Object System.Object
$Preview | Add-Member -type NoteProperty -name Name -Value "Preview"
$Preview | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.Preview)
$Preview | Add-Member -type NoteProperty -name Syntax -Value '$_.Title -match "Preview"'

$Itanium = New-Object System.Object
$Itanium | Add-Member -type NoteProperty -name Name -Value "Itanium"
$Itanium | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.Itanium)
$Itanium | Add-Member -type NoteProperty -name Syntax -Value '$_.LegacyName -match "ia64|itanium"'

$LanguagePacks = New-Object System.Object
$LanguagePacks | Add-Member -type NoteProperty -name Name -Value "LanguagePacks"
$LanguagePacks | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.LanguagePacks)
$LanguagePacks | Add-Member -type NoteProperty -name Syntax -Value '$_.Title -match "language\s"'

$IE7 = New-Object System.Object
$IE7 | Add-Member -type NoteProperty -name Name -Value "IE7"
$IE7 | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.IE7)
$IE7 | Add-Member -type NoteProperty -name Syntax -Value '$_.title -match "Internet Explorer 7"'

$IE8 = New-Object System.Object
$IE8 | Add-Member -type NoteProperty -name Name -Value "IE8"
$IE8 | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.IE8)
$IE8 | Add-Member -type NoteProperty -name Syntax -Value '$_.title -match "Internet Explorer 8"'

$IE9 = New-Object System.Object
$IE9 | Add-Member -type NoteProperty -name Name -Value "IE9"
$IE9 | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.IE9)
$IE9 | Add-Member -type NoteProperty -name Syntax -Value '$_.title -match "Internet Explorer 9"'

$IE10 = New-Object System.Object
$IE10 | Add-Member -type NoteProperty -name Name -Value "IE10"
$IE10 | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.IE10)
$IE10 | Add-Member -type NoteProperty -name Syntax -Value '$_.title -match "Internet Explorer 10"'

$Beta = New-Object System.Object
$Beta | Add-Member -type NoteProperty -name Name -Value "Beta"
$Beta | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.Beta)
$Beta | Add-Member -type NoteProperty -name Syntax -Value '$_.Title -match "Beta"'

$Embedded = New-Object System.Object
$Embedded | Add-Member -type NoteProperty -name Name -Value "Embedded"
$Embedded | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.Embedded)
$Embedded | Add-Member -type NoteProperty -name Syntax -Value '$_.title -match "Windows Embedded"'

$NonEnglishUpdates = New-Object System.Object
$NonEnglishUpdates | Add-Member -type NoteProperty -name Name -Value "NonEnglishUpdates"
$NonEnglishUpdates | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.NonEnglishUpdates)
$NonEnglishUpdates | Add-Member -type NoteProperty -name Syntax -Value '$_.title -match "Japanese" -or $_.title -match "Korean" -or $_.title -match "Taiwan"'

$ComputerUpdates32bit = New-Object System.Object
$ComputerUpdates32bit | Add-Member -type NoteProperty -name Name -Value "ComputerUpdates32bit"
$ComputerUpdates32bit | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.ComputerUpdates32bit)
$ComputerUpdates32bit | Add-Member -type NoteProperty -name Syntax -Value '$_.LegacyName -match "x86"'

$WinXP = New-Object System.Object
$WinXP | Add-Member -type NoteProperty -name Name -Value "WinXP"
$WinXP | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.WinXP)
$WinXP | Add-Member -type NoteProperty -name Syntax -Value '$_.LegacyName -match "XP" -or $_.producttitles -match "XP"'

$SharepointUpdates = New-Object System.Object
$SharepointUpdates | Add-Member -type NoteProperty -name Name -Value "SharepointUpdates"
$SharepointUpdates | Add-Member -type NoteProperty -name Decline -Value $($WSUSCleanDeclineMultipleTypesOfUpdatesList.SharepointUpdates)
$SharepointUpdates | Add-Member -type NoteProperty -name Syntax -Value '$_.IsApproved -and $_.Title -match "SharePoint"'

Write-Verbose "Create the array from all of the objects"
$TypesList = @()
$TypesList += $Superseded,$Expired, $Preview, $Itanium, $LanguagePacks, $IE7, $IE8, $IE9, $IE10, $Beta, $Embedded, $NonEnglishUpdates, $ComputerUpdates32bit, $WinXP

function DeclineMultipleTypesOfUpdates {
    param (
    [Switch]$Force
    )
    # Log the date first
    $DateNow = Get-Date
    Write-Output "WSUSClean Decline Multiple Types of Updates Stream"
    Write-Output ""
    Write-Verbose "Create an update scope"
    $UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
    #$UpdateScope.ApprovedStates = "Any"
    Write-Verbose "Let's grab all the updates on the server and stick them into a variable so we don't have to keep querying the database."
    $AllUpdatesList = $WSUSCleanWSUSServerAdminProxy.GetUpdates($UpdateScope)
    $WSUSCleanScheduledRunStreamsDayEnglish = $(
        if ($WSUSCleanScheduledRunStreamsDay -eq $DateNow.Day -or $FirstRun -eq $True) { "today" }
        else {
            if ($WSUSCleanScheduledRunStreamsDay -eq '1') {
                "on the $WSUSCleanScheduledRunStreamsDay" + "st"
            } elseif ($WSUSCleanScheduledRunStreamsDay -eq '2') {
                "on the $WSUSCleanScheduledRunStreamsDay" + "nd"
            } elseif ($WSUSCleanScheduledRunStreamsDay -eq '3') {
                "on the $WSUSCleanScheduledRunStreamsDay" + "rd"
            } else {
                "on the $WSUSCleanScheduledRunStreamsDay" + "th"
            }
        }
    )
    Write-Output "There are $($AllUpdatesList.Count) updates in this server's database."
    $WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT = "There are $($AllUpdatesList.Count) updates in this server's database.`r`n"
    $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "<p>There are $($AllUpdatesList.Count) updates in this server's database.<br />`r`n"
    Write-Output "There are $($TypesList.Count) types of updates that we're going to deal with $($WSUSCleanScheduledRunStreamsDayEnglish):"
    $WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT = "There are $($TypesList.Count) types of updates that we're going to deal with $($WSUSCleanScheduledRunStreamsDayEnglish):`r`n`r`n"
    $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "There are $($TypesList.Count) types of updates that we're going to deal with $($WSUSCleanScheduledRunStreamsDayEnglish):</p>`r`n`r`n"
    $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "<ol>`r`n"
    Write-Output ""
    $TypesList | ForEach-Object -Begin { $I=0 } -Process {
        $I = $I+1
        Write-Progress -Id 1 -Activity "Running through Decline Multiple Types Of Updates Stream" -Status "Currently Counting" -CurrentOperation "$($_.Name) updates" -PercentComplete ($I/$TypesList.count*100) -ParentId -1
        $TypesList_ = $_
        if ($_.Decline -eq $True) {
            Write-Verbose "On this iteration We are going to deal with: $($_.Name)."
            Write-Verbose "Let's query the `$AllUpdatesList which has the scope of `"$($UpdateScope.ApprovedStates)`" and store the results into a variable that we are going to work with."
            $TargetListConditions = "`$_.IsDeclined -eq `$False -and $($_.Syntax)"
            $TargetList = $AllUpdatesList | Where-Object { Invoke-Expression $TargetListConditions }
            if ($Force -eq $True -or $WSUSCleanScheduledRunStreamsDay -eq $DateNow.Day) {
                Write-Output "$($I). $($_.Name): Displaying the titles of the $($_.Name) updates that have been declined:"
                $WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT += "$($I). $($_.Name): Displaying the titles of the $($_.Name) updates that have been declined:`r`n"
                $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "`t<li>$($_.Name): Displaying the titles of the $($_.Name) updates that have been declined:</li>`r`n"
                if ($TargetList.Count -ne 0) {
                $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "`t<ol>`r`n"
                    $Count=0
                    $TargetList | ForEach-Object -Begin { $J=0 } -Process {
                        $J = $J+1
                        Write-Progress -Id 2 -Activity "Declining $($TypesList_.Name) updates" -Status "Progress" -PercentComplete ($J/$TargetList.Count*100) -ParentId 1
                        $Count++
                        Write-Output "`t$($Count). $($_.Title) - https://support.microsoft.com/en-us/kb/$($_.KnowledgebaseArticles)"
                        $WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT += "`t$($Count). $($_.Title) - https://support.microsoft.com/en-us/kb/$($_.KnowledgebaseArticles)`r`n"
                        $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "`t`t<li><a href=`"https://support.microsoft.com/en-us/kb$($_.KnowledgebaseArticles)`">$($_.Title)</a></li>`r`n"
                        $_.Decline()
                    }
                    Write-Progress -Id 2 -Activity "Declining $($TypesList_.Name) updates" -Completed
                } else {
                    Write-Output "`t$($_.Name) has no updates to decline."
                    $WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT += "`t$($_.Name) has no updates to decline.`r`n"
                    $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "`t<ol>`r`n`t`t<li>$($_.Name) has no updates to decline.</li>`r`n"
                    }
                $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "`t</ol>`r`n"
                Write-Progress -Id 2 -Activity "Declining $($TypesList_.Name) updates" -Completed
            } else {
                Write-Verbose "It is NOT THE streams day - Just Count it."
                Write-Output "$($I). $($_.Name): $($TargetList.Count)"
                $WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT += "$($I). $($_.Name): $($TargetList.Count)`r`n"
                $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "`t<li>$($_.Name): $($TargetList.Count)</li>`r`n"
                #Write-Output "There are currently updates to decline for."
            }
        } else {
            Write-Output "$($I). $($_.Name): Skipped"
            $WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT += "$($I). $($_.Name): Skipped`r`n"
            $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "`t<li>$($_.Name): Skipped</li>`r`n"
        }
        Write-Progress -Id 1 -Activity "Running through Decline Multiple Types Of Updates Stream" -Completed -ParentId -1
    }
    $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "</ol>`r`n`r`n"
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning
    Write-Output ""
    $Output = "Decline Multiple Types of Updates Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Output
    $Script:WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT += "WSUSClean Decline Multiple Types of Updates Stream:`r`n`r`n"
    $Script:WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Decline Multiple Types of Updates Stream:</span></p>`r`n`r`n"
    $Script:WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT += "$WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT`r`n"
    $Script:WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML
    $Script:WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT += "Decline Multiple Types of Updates Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML += "<p>Decline Multiple Types of Updates Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
}
#endregion DeclineMultipleTypesOfUpdates Function

#region ApplicationPoolMemory Function
################################
#   Application Pool Memory    #
#     Configuration Stream     #
################################
function ApplicationPoolMemory {
    Param(
    [ValidateRange(0,[int]::MaxValue)]
    [Int]$Set=-1
    )
    Write-Verbose "`$Set is set to $Set"
    $DateNow = Get-Date
    Import-Module WebAdministration
    $applicationPoolsPath = "/system.applicationHost/applicationPools"
    $applicationPools = Get-WebConfiguration $applicationPoolsPath
    foreach ($appPool in $applicationPools.Collection) {
	    if ($appPool.name -eq 'WsusPool') {
		    $appPoolPath = "$applicationPoolsPath/add[@name='$($appPool.Name)']"
		    $CurrentPrivateMemory = (Get-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory").Value
            Write-Output "Current Private Memory Limit for $($appPool.name) is: $($CurrentPrivateMemory/1000) MB"
            if ($set -ne '-1') {
                Write-Verbose "Setting the private memory limit to $Set MB"
                $Set=$Set * 1000
                Write-Verbose "Setting the primary memory limit to $Set Bytes"
                $NewPrivateMemory = $Set
                Write-Output "New Private Memory Limit for $($appPool.name) is: $($NewPrivateMemory/1000) MB"
                Set-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" -Value $NewPrivateMemory
                Write-Verbose "Restart the $($appPool.name) Application Pool to make the new settings take effect"
                Restart-WebAppPool -Name $($appPool.name)
            }
	    }
    }
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning
    $Duration = "{0:00}:{1:00}:{2:00}:{3:00}:{4:00}" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds})
    Write-Verbose "Application Pool Memory Stream Duration: $Duration"
}
#endregion ApplicationPoolMemory Function

#region RemoveWSUSDrivers Function
################################
#   WSUSClean Remove WSUS Drivers  #
#           Stream             #
################################

function RemoveWSUSDrivers {
    param (
        [Parameter()]
        [Switch] $SQL
    )
    function RemoveWSUSDriversSQL {
        $WSUSCleanRemoveWSUSDriversSQLScript = @"
/*
################################
#   WSUSClean WSUS Delete Drivers  #
#         SQL Script           #
#       Version 1.0            #
#  Taken from various sources  #
#      from the Internet.      #
#                              #
#  Modified By: WSUS Cleanup  #
#     http://www.WSUSClean.org     #
################################

-- Originally taken from http://www.flexecom.com/how-to-delete-driver-updates-from-wsus-3-0/
-- Modified to be dynamic and more of a nice output
*/
USE SUSDB;
GO

SET NOCOUNT ON;
DECLARE @tbrevisionlanguage nvarchar(255)
DECLARE @tbProperty nvarchar(255)
DECLARE @tbLocalizedPropertyForRevision nvarchar(255)
DECLARE @tbFileForRevision nvarchar(255)
DECLARE @tbInstalledUpdateSufficientForPrerequisite nvarchar(255)
DECLARE @tbPreRequisite nvarchar(255)
DECLARE @tbDeployment nvarchar(255)
DECLARE @tbXml nvarchar(255)
DECLARE @tbPreComputedLocalizedProperty nvarchar(255)
DECLARE @tbDriver nvarchar(255)
DECLARE @tbFlattenedRevisionInCategory nvarchar(255)
DECLARE @tbRevisionInCategory nvarchar(255)
DECLARE @tbMoreInfoURLForRevision nvarchar(255)
DECLARE @tbRevision nvarchar(255)
DECLARE @tbUpdateSummaryForAllComputers nvarchar(255)
DECLARE @tbUpdate nvarchar(255)
DECLARE @var1 nvarchar(255)

/*
This query gives you the GUID that you will need to substitute in all subsequent queries. In my case, it is
D2CB599A-FA9F-4AE9-B346-94AD54EE0629. I saw this GUID in several WSUS databases so I think it does not change;
at least not between WSUS 3.0 SP2 servers. Either way, we are setting a variable for this so this will
dynamically reference the correct GUID.
*/

SELECT @var1 = UpdateTypeID FROM tbUpdateType WHERE Name = 'Driver'

/*
The bad news is that WSUS database has over 100 tables. The good news is that SQL allows to enforce referential
integrity in data model designs, which in this case can be used to essentially reverse engineer a procedure,
that as far as I know isn't documented anywhere.

The trick is to delete all driver type records from tbUpdate table - but FIRST we have to delete all records in
all other tables (revisions, languages, dependencies, files, reports...), which refer to driver rows in tbUpdate.

Here's how this is done, in 16 tables/queries.
*/

delete from tbrevisionlanguage where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbrevisionlanguage = @@ROWCOUNT
PRINT 'Delete records from tbrevisionlanguage: ' + @tbrevisionlanguage

delete from tbProperty where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbProperty = @@ROWCOUNT
PRINT 'Delete records from tbProperty: ' + @tbProperty

delete from tbLocalizedPropertyForRevision where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbLocalizedPropertyForRevision = @@ROWCOUNT
PRINT 'Delete records from tbLocalizedPropertyForRevision: ' + @tbLocalizedPropertyForRevision

delete from tbFileForRevision where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbFileForRevision = @@ROWCOUNT
PRINT 'Delete records from tbFileForRevision: ' + @tbFileForRevision

delete from tbInstalledUpdateSufficientForPrerequisite where prerequisiteid in (select Prerequisiteid from tbPreRequisite where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1)))
SELECT @tbInstalledUpdateSufficientForPrerequisite = @@ROWCOUNT
PRINT 'Delete records from tbInstalledUpdateSufficientForPrerequisite: ' + @tbInstalledUpdateSufficientForPrerequisite

delete from tbPreRequisite where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbPreRequisite = @@ROWCOUNT
PRINT 'Delete records from tbPreRequisite: ' + @tbPreRequisite

delete from tbDeployment where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbDeployment = @@ROWCOUNT
PRINT 'Delete records from tbDeployment: ' + @tbDeployment

delete from tbXml where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbXml = @@ROWCOUNT
PRINT 'Delete records from tbXml: ' + @tbXml

delete from tbPreComputedLocalizedProperty where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbPreComputedLocalizedProperty = @@ROWCOUNT
PRINT 'Delete records from tbPreComputedLocalizedProperty: ' + @tbPreComputedLocalizedProperty

delete from tbDriver where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbDriver = @@ROWCOUNT
PRINT 'Delete records from tbDriver: ' + @tbDriver

delete from tbFlattenedRevisionInCategory where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbFlattenedRevisionInCategory = @@ROWCOUNT
PRINT 'Delete records from tbFlattenedRevisionInCategory: ' + @tbFlattenedRevisionInCategory

delete from tbRevisionInCategory where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbRevisionInCategory = @@ROWCOUNT
PRINT 'Delete records from tbRevisionInCategory: ' + @tbRevisionInCategory

delete from tbMoreInfoURLForRevision where revisionid in (select revisionid from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1))
SELECT @tbMoreInfoURLForRevision = @@ROWCOUNT
PRINT 'Delete records from tbMoreInfoURLForRevision: ' + @tbMoreInfoURLForRevision

delete from tbRevision where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1)
SELECT @tbRevision = @@ROWCOUNT
PRINT 'Delete records from tbRevision: ' + @tbRevision

delete from tbUpdateSummaryForAllComputers where LocalUpdateId in (select LocalUpdateId from tbUpdate where UpdateTypeID = @var1)
SELECT @tbUpdateSummaryForAllComputers = @@ROWCOUNT
PRINT 'Delete records from tbUpdateSummaryForAllComputers: ' + @tbUpdateSummaryForAllComputers

PRINT CHAR(13)+CHAR(10) + 'This is the last query and this is really what we came here for.'

delete from tbUpdate where UpdateTypeID = @var1
SELECT @tbUpdate = @@ROWCOUNT
PRINT 'Delete records from tbUpdate: ' + @tbUpdate

/*
If at this point you get an error saying something about foreign key constraint, that will be most likely
due to the difference between which reports I ran in my WSUS installation and which reports were ran against
your particular installation. Fortunately, the error gives you exact location (table) where this constraint
is violated, so you can adjust one of the queries in the batch above to delete references in any other tables.
*/
"@
        Write-Verbose "Create a file with the content of the RemoveWSUSDrivers Script above in the same working directory as this PowerShell script is running."
        $WSUSCleanRemoveWSUSDriversSQLScriptFile = "$WSUSCleanScriptPath\WSUSCleanRemoveWSUSDrivers.sql"
        $WSUSCleanRemoveWSUSDriversSQLScript | Out-File "$WSUSCleanRemoveWSUSDriversSQLScriptFile"
        # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
        $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
        Write-Verbose "Execute the SQL Script and store the results in a variable."
        $WSUSCleanRemoveWSUSDriversSQLScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanRemoveWSUSDriversSQLScriptFile`" -I")
        Write-Verbose "`$WSUSCleanRemoveWSUSDriversSQLScriptJobCommand = $WSUSCleanRemoveWSUSDriversSQLScriptJobCommand"
        $WSUSCleanRemoveWSUSDriversSQLScriptJob = Start-Job -ScriptBlock $WSUSCleanRemoveWSUSDriversSQLScriptJobCommand
        Wait-Job $WSUSCleanRemoveWSUSDriversSQLScriptJob
        $WSUSCleanRemoveWSUSDriversSQLScriptJobOutput = Receive-Job $WSUSCleanRemoveWSUSDriversSQLScriptJob
        Remove-Job $WSUSCleanRemoveWSUSDriversSQLScriptJob
        Write-Verbose "Remove the SQL Script file."
        Remove-Item "$WSUSCleanRemoveWSUSDriversSQLScriptFile"
        $Script:WSUSCleanRemoveWSUSDriversSQLOutputTXT = $WSUSCleanRemoveWSUSDriversSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n`r`n"
        $Script:WSUSCleanRemoveWSUSDriversSQLOutputHTML = $WSUSCleanRemoveWSUSDriversSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n"

        # Variables Output
        # $WSUSCleanRemoveWSUSDriversSQLOutputTXT
        # $WSUSCleanRemoveWSUSDriversSQLOutputHTML

    }
    function RemoveWSUSDriversPS {
        $Count = 0
        $WSUSCleanWSUSServerAdminProxy.GetUpdates() | Where-Object { $_.IsDeclined -eq $true -and $_.UpdateClassificationTitle -eq "Drivers" } | ForEach-Object {
            # Delete these updates
            $WSUSCleanWSUSServerAdminProxy.DeleteUpdate($_.Id.UpdateId.ToString())
            $DeleteDeclinedDriverTitle = $_.Title
            $Count++
            $WSUSCleanRemoveWSUSDriversPSDeleteOutputTXT += "$($Count). $($DeleteDeclinedDriverTitle)`n`n"
            $WSUSCleanRemoveWSUSDriversPSDeleteOutputHTML += "<li>$DeleteDeclinedDriverTitle</li>`n"
        }
        $WSUSCleanRemoveWSUSDriversPSDeleteOutputTXT += "`n`n"
        $WSUSCleanRemoveWSUSDriversPSDeleteOutputHTML += "</ol>`n"

        $Script:WSUSCleanRemoveWSUSDriversPSOutputTXT += "`n`n"
        $Script:WSUSCleanRemoveWSUSDriversPSOutputHTML += "<ol>`n"
        $Script:WSUSCleanRemoveWSUSDriversPSOutputTXT += $WSUSCleanRemoveWSUSDriversPSDeleteOutputTXT
        $Script:WSUSCleanRemoveWSUSDriversPSOutputHTML += $WSUSCleanRemoveWSUSDriversPSDeleteOutputHTML

        # Variables Output
        # $WSUSCleanRemoveWSUSDriversPSOutputTXT
        # $WSUSCleanRemoveWSUSDriversPSOutputHTML
    }
    # Process the appropriate internal function
    $DateNow = Get-Date
    if ($SQL -eq $True) { RemoveWSUSDriversSQL } else { RemoveWSUSDriversPS }
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning
    # Create the output for the RemoveWSUSDrivers function
    $Script:WSUSCleanRemoveWSUSDriversOutputTXT += "WSUSClean Remove WSUS Drivers:`n`n"
    $Script:WSUSCleanRemoveWSUSDriversOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Remove WSUS Drivers:</span></p>`n"
    if ($SQL -eq $True) {
        $Script:WSUSCleanRemoveWSUSDriversOutputTXT += $WSUSCleanRemoveWSUSDriversSQLOutputTXT
        $Script:WSUSCleanRemoveWSUSDriversOutputHTML += $WSUSCleanRemoveWSUSDriversSQLOutputHTML
    } else {
        $Script:WSUSCleanRemoveWSUSDriversOutputTXT += $WSUSCleanRemoveWSUSDriversPSOutputTXT
        $Script:WSUSCleanRemoveWSUSDriversOutputHTML += $WSUSCleanRemoveWSUSDriversPSOutputHTML
    }
    $Script:WSUSCleanRemoveWSUSDriversOutputTXT += "Remove WSUS Drivers Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanRemoveWSUSDriversOutputHTML += "<p>Remove WSUS Drivers Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanRemoveWSUSDriversOutputTXT
    # $WSUSCleanRemoveWSUSDriversOutputHTML
}
#endregion RemoveWSUSDrivers Function

#region WSUSIndexOptimization Function
################################
#       WSUSClean WSUS Index       #
#     Optimization Stream      #
################################

function WSUSIndexOptimization {
    Param (
    )
  $DateNow = Get-Date
  $WSUSCleanWSUSIndexOptimizationSQLScript = @"
USE [SUSDB]
GO
/****** Object:  Index [WSUSClean_IX_TargetGroupTypeID_LastChangeNumber_UpdateType]    Script Date: 2017-06-05 17:22:17 ******/
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'WSUSClean_IX_TargetGroupTypeID_LastChangeNumber_UpdateType' AND object_id = OBJECT_ID('[dbo].[tbDeadDeployment]'))
    BEGIN
        PRINT 'WSUSClean_IX_TargetGroupTypeID_LastChangeNumber_UpdateType on [dbo].[tbDeadDeployment] doesn''t exist. Creating...'
        CREATE NONCLUSTERED INDEX [WSUSClean_IX_TargetGroupTypeID_LastChangeNumber_UpdateType] ON [dbo].[tbDeadDeployment]
        (
	        [TargetGroupTypeID] ASC,
	        [LastChangeNumber] ASC,
	        [UpdateType] ASC
        )
        INCLUDE ( 	[TargetGroupID],
	        [UpdateID],
	        [RevisionNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        PRINT 'Done.'
    END
ELSE
	BEGIN
		PRINT 'WSUSClean_IX_TargetGroupTypeID_LastChangeNumber_UpdateType on [dbo].[tbDeadDeployment] already created. No changes made.'
	END
/****** Object:  Index [WSUSClean_IX_RevisionID_ActionID_DeploymentStatus___UpdateType]    Script Date: 2017-06-05 17:22:40 ******/
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'WSUSClean_IX_RevisionID_ActionID_DeploymentStatus___UpdateType' AND object_id = OBJECT_ID('[dbo].[tbDeployment]'))
    BEGIN
        PRINT 'WSUSClean_IX_RevisionID_ActionID_DeploymentStatus___UpdateType on [dbo].[tbDeployment] doesn''t exist. Creating...'
        CREATE NONCLUSTERED INDEX [WSUSClean_IX_RevisionID_ActionID_DeploymentStatus___UpdateType] ON [dbo].[tbDeployment]
        (
	        [RevisionID] ASC,
	        [ActionID] ASC,
	        [DeploymentStatus] ASC
        )
        INCLUDE ( 	[UpdateType]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
        PRINT 'Done.'
    END
ELSE
	BEGIN
		PRINT 'WSUSClean_IX_RevisionID_ActionID_DeploymentStatus___UpdateType on [dbo].[tbDeployment] already created. No changes made.'
	END
/****** Object:  Index [WSUSClean_IX_ActualState]    Script Date: 2017-06-05 17:27:34 ******/
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'WSUSClean_IX_ActualState' AND object_id = OBJECT_ID('[dbo].[tbFileOnServer]'))
    BEGIN
        PRINT 'WSUSClean_IX_ActualState on [dbo].[tbFileOnServer] doesn''t exist. Creating...'
        CREATE NONCLUSTERED INDEX [WSUSClean_IX_ActualState] ON [dbo].[tbFileOnServer]
        (
	        [ActualState] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
        PRINT 'Done.'
    END
ELSE
	BEGIN
		PRINT 'WSUSClean_IX_ActualState on [dbo].[tbFileOnServer] already created. No changes made.'
	END
/****** Object:  Index [WSUSClean_IX_LocalizedPropertyID]    Script Date: 2017-06-05 17:28:14 ******/
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'WSUSClean_IX_LocalizedPropertyID' AND object_id = OBJECT_ID('[dbo].[tbLocalizedProperty]'))
    BEGIN
        PRINT 'WSUSClean_IX_LocalizedPropertyID on [dbo].[tbLocalizedProperty] doesn''t exist. Creating...'
        CREATE NONCLUSTERED INDEX [WSUSClean_IX_LocalizedPropertyID] ON [dbo].[tbLocalizedProperty]
        (
	        [LocalizedPropertyID] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        PRINT 'Done.'
    END
ELSE
	BEGIN
		PRINT 'WSUSClean_IX_LocalizedPropertyID on [dbo].[tbLocalizedProperty] already created. No changes made.'
	END
/****** Object:  Index [WSUSClean_IX_LocalizedPropertyID]    Script Date: 2017-06-05 17:28:38 ******/
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'WSUSClean_IX_LocalizedPropertyID' AND object_id = OBJECT_ID('[dbo].[tbLocalizedPropertyForRevision]'))
    BEGIN
        PRINT 'WSUSClean_IX_LocalizedPropertyID on [dbo].[tbLocalizedPropertyForRevision] doesn''t exist. Creating...'
        CREATE NONCLUSTERED INDEX [WSUSClean_IX_LocalizedPropertyID] ON [dbo].[tbLocalizedPropertyForRevision]
        (
	        [LocalizedPropertyID] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        PRINT 'Done.'
    END
ELSE
	BEGIN
		PRINT 'WSUSClean_IX_LocalizedPropertyID on [dbo].[tbLocalizedPropertyForRevision] already created. No changes made.'
	END
/****** Object:  Index [WSUSClean_IX_RowID_RevisionID]    Script Date: 2017-06-05 17:29:12 ******/
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'WSUSClean_IX_RowID_RevisionID' AND object_id = OBJECT_ID('[dbo].[tbRevision]'))
    BEGIN
        PRINT 'WSUSClean_IX_RowID_RevisionID on [dbo].[tbRevision] doesn''t exist. Creating...'
        CREATE NONCLUSTERED INDEX [WSUSClean_IX_RowID_RevisionID] ON [dbo].[tbRevision]
        (
	        [RowID] ASC,
	        [RevisionID] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
        PRINT 'Done.'
    END
ELSE
	BEGIN
		PRINT 'WSUSClean_IX_RowID_RevisionID on [dbo].[tbRevision] already created. No changes made.'
	END
/****** Object:  Index [WSUSClean_IX_SupersededUpdateID]    Script Date: 2017-06-05 17:29:42 ******/
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'WSUSClean_IX_SupersededUpdateID' AND object_id = OBJECT_ID('[dbo].[tbRevisionSupersedesUpdate]'))
    BEGIN
        PRINT 'WSUSClean_IX_SupersededUpdateID on [dbo].[tbRevisionSupersedesUpdate] doesn''t exist. Creating...'
        CREATE NONCLUSTERED INDEX [WSUSClean_IX_SupersededUpdateID] ON [dbo].[tbRevisionSupersedesUpdate]
        (
	        [SupersededUpdateID] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
        PRINT 'Done.'
    END
ELSE
	BEGIN
		PRINT 'WSUSClean_IX_SupersededUpdateID on [dbo].[tbRevisionSupersedesUpdate] already created. No changes made.'
	END
"@
    Write-Verbose "Create a file with the content of the WSUSIndexOptimization Script above in the same working directory as this PowerShell script is running."
    $WSUSCleanWSUSIndexOptimizationSQLScriptFile = "$WSUSCleanScriptPath\WSUSCleanWSUSIndexOptimization.sql"
    $WSUSCleanWSUSIndexOptimizationSQLScript | Out-File "$WSUSCleanWSUSIndexOptimizationSQLScriptFile"

    # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
    $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
    Write-Verbose "Execute the SQL Script and store the results in a variable."
    $WSUSCleanWSUSIndexOptimizationSQLScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanWSUSIndexOptimizationSQLScriptFile`" -I")
    Write-Verbose "`$WSUSCleanWSUSIndexOptimizationSQLScriptJob = $WSUSCleanWSUSIndexOptimizationSQLScriptJobCommand"
    $WSUSCleanWSUSIndexOptimizationSQLScriptJob = Start-Job -ScriptBlock $WSUSCleanWSUSIndexOptimizationSQLScriptJobCommand
    Wait-Job $WSUSCleanWSUSIndexOptimizationSQLScriptJob
    $WSUSCleanWSUSIndexOptimizationSQLScriptJobOutput = Receive-Job $WSUSCleanWSUSIndexOptimizationSQLScriptJob
    Remove-Job $WSUSCleanWSUSIndexOptimizationSQLScriptJob
    Write-Verbose "Remove the SQL Script file."
    Remove-Item "$WSUSCleanWSUSIndexOptimizationSQLScriptFile"
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning
    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    $Script:WSUSCleanWSUSIndexOptimizationOutputTXT += "WSUSClean WSUS Index Optimization:`r`n`r`n"
    $Script:WSUSCleanWSUSIndexOptimizationOutputTXT += $WSUSCleanWSUSIndexOptimizationSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n"
    $Script:WSUSCleanWSUSIndexOptimizationOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean WSUS Index Optimization:</span></p>`n`n"
    $Script:WSUSCleanWSUSIndexOptimizationOutputHTML += $WSUSCleanWSUSIndexOptimizationSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n"
    $Script:WSUSCleanWSUSIndexOptimizationOutputTXT += "WSUSClean WSUS Index Optimization Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanWSUSIndexOptimizationOutputHTML += "<p>WSUSClean WSUS Index Optimization Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanWSUSIndexOptimizationOutputTXT
    # $WSUSCleanWSUSIndexOptimizationOutputHTML
}
#endregion WSUSIndexOptimization Function

#region RemoveDeclinedWSUSUpdates Function
################################
#  WSUSClean Remove Declined WSUS  #
#       Updates Stream         #
################################

function RemoveDeclinedWSUSUpdates {
    param (
    [Switch]$Display,
    [Switch]$Proceed
    )
    # Log the date first
    $DateNow = Get-Date
    Write-Verbose "Create an update scope"
    $UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
    Write-Verbose "By default the update scope is created for any approval states"
    $UpdateScope.ApprovedStates = "Any"
    Write-Verbose "Get all updates that are Declined"
    $WSUSCleanRemoveDeclinedWSUSUpdatesUpdates = $WSUSCleanWSUSServerAdminProxy.GetUpdates($UpdateScope) | Where { ($_.isDeclined) }
    function RemoveDeclinedWSUSUpdatesCountUpdates {
        Write-Verbose "First count how many updates will be removed that are already declined updates - just for fun. I like fun :)"
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesCount = "{0:N0}" -f $WSUSCleanRemoveDeclinedWSUSUpdatesUpdates.Count
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesOutputTXT += "The number of declined updates that would be removed from the database are: $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesCount.`r`n`r`n"
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesOutputHTML += "<p>The number of declined updates that would be removed from the database are: $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesCount.</p>`n"

         # Variables Output
         # $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesOutputTXT
         # $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesOutputHTML
    }

    function RemoveDeclinedWSUSUpdatesDisplayUpdates {
        Write-Verbose "Display the titles of the declined updates that will be removed from the database - just for fun. I like fun :)"
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputHTML += "<ol>`n"
        $Count=0
        ForEach ($update in $WSUSCleanRemoveDeclinedWSUSUpdatesUpdates) {
            $Count++
            $Script:WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputTXT += "$($Count). $($update.title) - https://support.microsoft.com/en-us/kb/$($update.KnowledgebaseArticles)`r`n"
            $Script:WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputHTML += "<li><a href=`"https://support.microsoft.com/en-us/kb/$($update.KnowledgebaseArticles)`">$($update.title)</a></li>`n"
        }
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputTXT += "`r`n"
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputHTML += "</ol>`n"

        # Variables Output
        # $WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputTXT
        # $WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputHTML
    }

    function RemoveDeclinedWSUSUpdatesProceed {
        Write-Output "You've chosen to remove declined updates from the database. Removing $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesCount declined updates."
        Write-Output ""
        Write-Output "Please be patient, this may take a while."
        Write-Output ""
        Write-Output "It is not abnormal for this process to take minutes or hours. It varies per install and per execution."
        Write-Output ""
        Write-Output "Any errors received are due to updates that are shared between systems. Eg. A Windows 7 update may share itself also with a Server 2008 update."
        Write-Output ""
        Write-Output "If you cancel this process (CTRL-C/Close the window), you will lose the documentation/log of what has happened thusfar, but it will resume where it left off when you run it again."
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputTXT += "You've chosen to remove declined updates from the database. Removing $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesCount declined updates.`r`n`r`n"
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputHTML += "<p>You've chosen to remove declined updates from the database. <strong>Removing $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesCount declined updates.</strong></p>`n"
        # Remove these updates
        $WSUSCleanRemoveDeclinedWSUSUpdatesUpdates | ForEach-Object {
            $DeleteID = $_.Id.UpdateId.ToString()
            Try {
                $WSUSCleanRemoveDeclinedWSUSUpdatesUpdateTitle = $($_.Title)
                Write-Output "Deleting" $WSUSCleanRemoveDeclinedWSUSUpdatesUpdateTitle
                $WSUSCleanWSUSServerAdminProxy.DeleteUpdate($DeleteId)
            }
            Catch {
                $ExceptionError = $_.Exception
                if ([string]::isnullorempty($WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsTXT)) { $WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsTXT = "" }
                if ([string]::isnullorempty($WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsHTML)) { $WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsHTML = "" }
                $WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsTXT += "Error: $WSUSCleanRemoveDeclinedWSUSUpdatesUpdateTitle`r`n`r`n$ExceptionError.InnerException`r`n`r`n"
                $WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsHTML += "<li><p>$WSUSCleanRemoveDeclinedWSUSUpdatesUpdateTitle</p>$ExceptionError.InnerException</li>"
            }
            Finally {
                if ($ExceptionError) {
                    Write-Output "Errors:" $ExceptionError.Message
                    Remove-Variable ExceptionError
                } else {
                    Write-Verbose "Successful"
                }
            }
        }
        if (-not [string]::isnullorempty($WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsTXT)) {
            $Script:WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputTXT += "*** Errors Removing Declined WSUS Updates ***`r`n"
            $Script:WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputTXT += $WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsTXT
            $Script:WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputTXT += "`r`n`r`n"
        }
        if (-not [string]::isnullorempty($WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsHTML)) {
            $Script:WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputHTML += "<div class='error'><h1>Errors Removing Declined WSUS Updates</h1><ol start='1'>"
            $Script:WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputHTML += $WSUSCleanRemoveDeclinedWSUSUpdatesProceedExceptionsHTML
            $Script:WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputHTML += "</ol></div>"
        }

        # Variables Output
        # $WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputTXT
        # $WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputHTML
    }

    RemoveDeclinedWSUSUpdatesCountUpdates
    if ($Display -ne $False) { RemoveDeclinedWSUSUpdatesDisplayUpdates }
    if ($Proceed -ne $False) { RemoveDeclinedWSUSUpdatesProceed }
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning

    $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputTXT += "WSUSClean Remove Declined WSUS Updates:`r`n`r`n"
    $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Remove Declined WSUS Updates:</span></p>`n<ol>`n"
    $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputTXT += $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesOutputTXT
    $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputHTML += $WSUSCleanRemoveDeclinedWSUSUpdatesCountUpdatesOutputHTML
    if ($Display -ne $False) {
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputTXT += $WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputTXT
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputHTML += $WSUSCleanRemoveDeclinedWSUSUpdatesDisplayOutputHTML
    }
    if ($Proceed -ne $False) {
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputTXT += $WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputTXT
        $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputHTML += $WSUSCleanRemoveDeclinedWSUSUpdatesProceedOutputHTML
    }
    $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputTXT += "Remove Declined WSUS Updates Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanRemoveDeclinedWSUSUpdatesOutputHTML += "<p>Remove Declined WSUS Updates Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanRemoveDeclinedWSUSUpdatesOutputTXT
    # $WSUSCleanRemoveDeclinedWSUSUpdatesOutputHTML
}
#endregion RemoveDeclinedWSUSUpdates Function

#region CompressUpdateRevisions Function
################################
#    WSUSClean Compress Update     #
#       Revisions Stream       #
################################

function CompressUpdateRevisions {
    Param (
    )
  $DateNow = Get-Date
  $WSUSCleanCompressUpdateRevisionsSQLScript = @"
USE SUSDB;
GO
-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
SET NOCOUNT ON

DECLARE @var1 INT, @curitem INT, @totaltocompress INT
DECLARE @msg nvarchar(200)

IF EXISTS (
    SELECT * FROM tempdb.dbo.sysobjects o
    WHERE o.xtype IN ('U')
	AND o.id = object_id(N'tempdb..#results')
)
DROP TABLE #results
CREATE TABLE #results (Col1 INT)

-- Compress Update Revisions
INSERT INTO #results(Col1) EXEC spGetUpdatesToCompress
SET @totaltocompress = (SELECT COUNT(*) FROM #results)
SELECT @curitem=1
DECLARE WC Cursor FOR SELECT Col1 FROM #results;
OPEN WC
FETCH NEXT FROM WC INTO @var1 WHILE (@@FETCH_STATUS > -1)
BEGIN
	SET @msg = cast(@curitem as varchar(5)) + '/' + cast(@totaltocompress as varchar(5)) + ': Compressing ' + CONVERT(varchar(10), @var1) + ' ' + cast(getdate() as varchar(30))
	RAISERROR(@msg,0,1) WITH NOWAIT
	EXEC spCompressUpdate @localUpdateID=@var1
	SET @curitem = @curitem +1
	FETCH NEXT FROM WC INTO @var1
END
CLOSE WC
DEALLOCATE WC
DROP TABLE #results
"@
    Write-Verbose "Create a file with the content of the CompressUpdateRevisions Script above in the same working directory as this PowerShell script is running."
    $WSUSCleanCompressUpdateRevisionsSQLScriptFile = "$WSUSCleanScriptPath\WSUSCleanCompressUpdateRevisions.sql"
    $WSUSCleanCompressUpdateRevisionsSQLScript | Out-File "$WSUSCleanCompressUpdateRevisionsSQLScriptFile"

    # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
    $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
    Write-Verbose "Execute the SQL Script and store the results in a variable."
    $WSUSCleanCompressUpdateRevisionsSQLScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanCompressUpdateRevisionsSQLScriptFile`" -I")
    Write-Verbose "`$WSUSCleanCompressUpdateRevisionsSQLScriptJob = $WSUSCleanCompressUpdateRevisionsSQLScriptJobCommand"
    $WSUSCleanCompressUpdateRevisionsSQLScriptJob = Start-Job -ScriptBlock $WSUSCleanCompressUpdateRevisionsSQLScriptJobCommand
    Wait-Job $WSUSCleanCompressUpdateRevisionsSQLScriptJob
    $WSUSCleanCompressUpdateRevisionsSQLScriptJobOutput = Receive-Job $WSUSCleanCompressUpdateRevisionsSQLScriptJob
    Remove-Job $WSUSCleanCompressUpdateRevisionsSQLScriptJob
    Write-Verbose "Remove the SQL Script file."
    Remove-Item "$WSUSCleanCompressUpdateRevisionsSQLScriptFile"
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning
    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    $Script:WSUSCleanCompressUpdateRevisionsOutputTXT += "WSUSClean Compress Update Revisions:`r`n`r`n"
    $Script:WSUSCleanCompressUpdateRevisionsOutputTXT += $WSUSCleanCompressUpdateRevisionsSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n"
    $Script:WSUSCleanCompressUpdateRevisionsOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Compress Update Revisions:</span></p>`n`n"
    $Script:WSUSCleanCompressUpdateRevisionsOutputHTML += $WSUSCleanCompressUpdateRevisionsSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n"
    $Script:WSUSCleanCompressUpdateRevisionsOutputTXT += "WSUSClean Compress Update Revisions Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanCompressUpdateRevisionsOutputHTML += "<p>WSUSClean Compress Update Revisions Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanCompressUpdateRevisionsOutputTXT
    # $WSUSCleanCompressUpdateRevisionsOutputHTML
}
#endregion CompressUpdateRevisions Function

#region RemoveObsoleteUpdates Function
################################
#    WSUSClean Remove Obsolete     #
#        Updates Stream        #
################################

function RemoveObsoleteUpdates {
    Param (
    )
  $DateNow = Get-Date
  $WSUSCleanRemoveObsoleteUpdatesSQLScript = @"
USE SUSDB;
GO
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON

DECLARE @var1 INT, @curitem INT, @totaltoremove INT
DECLARE @msg nvarchar(200)

IF EXISTS (
    SELECT * FROM tempdb.dbo.sysobjects o
    WHERE o.xtype IN ('U')
	AND o.id = object_id(N'tempdb..#results')
)
DROP TABLE #results
CREATE TABLE #results (Col1 INT)

-- Remove Obsolete Updates
INSERT INTO #results(Col1) EXEC spGetObsoleteUpdatesToCleanup
SET @totaltoremove = (SELECT COUNT(*) FROM #results)
SELECT @curitem=1
DECLARE WC Cursor FOR SELECT Col1 FROM #results
OPEN WC
FETCH NEXT FROM WC INTO @var1 WHILE (@@FETCH_STATUS > -1)
BEGIN
	SET @msg = cast(@curitem as varchar(5)) + '/' + cast(@totaltoremove as varchar(5)) + ': Deleting ' + CONVERT(varchar(10), @var1) + ' ' + cast(getdate() as varchar(30))
	RAISERROR(@msg,0,1) WITH NOWAIT
	EXEC spDeleteUpdate @localUpdateID=@var1
	SET @curitem = @curitem +1
	FETCH NEXT FROM WC INTO @var1
END
CLOSE WC
DEALLOCATE WC
DROP TABLE #results
"@
    Write-Output ""
    Write-Output "Please be patient, this may take a while."
    Write-Output ""
    Write-Output "It is not abnormal for this process to take minutes or hours. It varies per install and per execution."
    Write-Output ""
    Write-Output "If you cancel this process (CTRL-C/Close the window), you will lose the documentation/log of what has happened thusfar, but it will resume where it left off when you run it again."
    Write-Verbose "Create a file with the content of the RemoveObsoleteUpdates Script above in the same working directory as this PowerShell script is running."
    $WSUSCleanRemoveObsoleteUpdatesSQLScriptFile = "$WSUSCleanScriptPath\WSUSCleanRemoveObsoleteUpdates.sql"
    $WSUSCleanRemoveObsoleteUpdatesSQLScript | Out-File "$WSUSCleanRemoveObsoleteUpdatesSQLScriptFile"
    Write-Debug "Just wrote to script file"
    # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
    $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
    Write-Verbose "Execute the SQL Script and store the results in a variable."
    $WSUSCleanRemoveObsoleteUpdatesSQLScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanRemoveObsoleteUpdatesSQLScriptFile`" -I")
    Write-Verbose "`$WSUSCleanRemoveObsoleteUpdatesSQLScriptJobCommand = $WSUSCleanRemoveObsoleteUpdatesSQLScriptJobCommand"
    $WSUSCleanRemoveObsoleteUpdatesSQLScriptJob = Start-Job -ScriptBlock $WSUSCleanRemoveObsoleteUpdatesSQLScriptJobCommand
    Wait-Job $WSUSCleanRemoveObsoleteUpdatesSQLScriptJob
    $WSUSCleanRemoveObsoleteUpdatesSQLScriptJobOutput = Receive-Job $WSUSCleanRemoveObsoleteUpdatesSQLScriptJob
    Write-Debug "Just finished - check WSUSCleanRemoveObsoleteUpdatesSQLScriptJobOutput"
    Remove-Job $WSUSCleanRemoveObsoleteUpdatesSQLScriptJob
    Write-Verbose "Remove the SQL Script file."
    Remove-Item "$WSUSCleanRemoveObsoleteUpdatesSQLScriptFile"
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning
    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    $Script:WSUSCleanRemoveObsoleteUpdatesOutputTXT += "WSUSClean Remove Obsolete Updates:`r`n`r`n"
    $Script:WSUSCleanRemoveObsoleteUpdatesOutputTXT += $WSUSCleanRemoveObsoleteUpdatesSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n"
    $Script:WSUSCleanRemoveObsoleteUpdatesOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Remove Obsolete Updates:</span></p>`n`n"
    $Script:WSUSCleanRemoveObsoleteUpdatesOutputHTML += $WSUSCleanRemoveObsoleteUpdatesSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n"
    $Script:WSUSCleanRemoveObsoleteUpdatesOutputTXT += "WSUSClean Remove Obsolete Updates Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanRemoveObsoleteUpdatesOutputHTML += "<p>WSUSClean Remove Obsolete Updates Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanRemoveObsoleteUpdatesOutputTXT
    # $WSUSCleanRemoveObsoleteUpdatesOutputHTML
}
#endregion RemoveObsoleteUpdates Function

#region WSUSDBMaintenance Function
################################
#  WSUSClean WSUS DB Maintenance   #
#            Stream            #
################################

function WSUSDBMaintenance {
    Param (
    [Switch]$NoOutput
    )
  $DateNow = Get-Date
  $WSUSCleanWSUSDBMaintenanceSQLScript = @"
/*
################################
#   WSUSClean WSUSDBMaintenance    #
#         SQL Script           #
#       Version 1.0            #
#      Taken from TechNet      #
#      referenced below.       #
#                              #
#        WSUS Cleanup         #
#     http://www.WSUSClean.org     #
################################
*/
-- Taken from https://gallery.technet.microsoft.com/scriptcenter/6f8cde49-5c52-4abd-9820-f1d270ddea61

/******************************************************************************
This sample T-SQL script performs basic maintenance tasks on SUSDB
1. Identifies indexes that are fragmented and defragments them. For certain
   tables, a fill-factor is set in order to improve insert performance.
   Based on MSDN sample at http://msdn2.microsoft.com/en-us/library/ms188917.aspx
   and tailored for SUSDB requirements
2. Updates potentially out-of-date table statistics.
******************************************************************************/

USE SUSDB;
GO
SET NOCOUNT ON;

-- Rebuild or reorganize indexes based on their fragmentation levels
DECLARE @work_to_do TABLE (
    objectid int
    , indexid int
    , pagedensity float
    , fragmentation float
    , numrows int
)

DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @schemaname nvarchar(130);
DECLARE @objectname nvarchar(130);
DECLARE @indexname nvarchar(130);
DECLARE @numrows int
DECLARE @density float;
DECLARE @fragmentation float;
DECLARE @command nvarchar(4000);
DECLARE @fillfactorset bit
DECLARE @numpages int

-- Select indexes that need to be defragmented based on the following
-- * Page density is low
-- * External fragmentation is high in relation to index size
PRINT 'Estimating fragmentation: Begin. ' + convert(nvarchar, getdate(), 121)
INSERT @work_to_do
SELECT
    f.object_id
    , index_id
    , avg_page_space_used_in_percent
    , avg_fragmentation_in_percent
    , record_count
FROM
    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL , NULL, 'SAMPLED') AS f
WHERE
    (f.avg_page_space_used_in_percent < 85.0 and f.avg_page_space_used_in_percent/100.0 * page_count < page_count - 1)
    or (f.page_count > 50 and f.avg_fragmentation_in_percent > 15.0)
    or (f.page_count > 10 and f.avg_fragmentation_in_percent > 80.0)

PRINT 'Number of indexes to rebuild: ' + cast(@@ROWCOUNT as nvarchar(20))

PRINT 'Estimating fragmentation: End. ' + convert(nvarchar, getdate(), 121)

SELECT @numpages = sum(ps.used_page_count)
FROM
    @work_to_do AS fi
    INNER JOIN sys.indexes AS i ON fi.objectid = i.object_id and fi.indexid = i.index_id
    INNER JOIN sys.dm_db_partition_stats AS ps on i.object_id = ps.object_id and i.index_id = ps.index_id

-- Declare the cursor for the list of indexes to be processed.
DECLARE curIndexes CURSOR FOR SELECT * FROM @work_to_do

-- Open the cursor.
OPEN curIndexes

-- Loop through the indexes
WHILE (1=1)
BEGIN
    FETCH NEXT FROM curIndexes
    INTO @objectid, @indexid, @density, @fragmentation, @numrows;
    IF @@FETCH_STATUS < 0 BREAK;

    SELECT
        @objectname = QUOTENAME(o.name)
        , @schemaname = QUOTENAME(s.name)
    FROM
        sys.objects AS o
        INNER JOIN sys.schemas as s ON s.schema_id = o.schema_id
    WHERE
        o.object_id = @objectid;

    SELECT
        @indexname = QUOTENAME(name)
        , @fillfactorset = CASE fill_factor WHEN 0 THEN 0 ELSE 1 END
    FROM
        sys.indexes
    WHERE
        object_id = @objectid AND index_id = @indexid;

    IF ((@density BETWEEN 75.0 AND 85.0) AND @fillfactorset = 1) OR (@fragmentation < 30.0)
        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REORGANIZE';
    ELSE IF @numrows >= 5000 AND @fillfactorset = 0
        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD WITH (FILLFACTOR = 90)';
    ELSE
        SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD';
    PRINT convert(nvarchar, getdate(), 121) + N' Executing: ' + @command;
    EXEC (@command);
    PRINT convert(nvarchar, getdate(), 121) + N' Done.';
END

-- Close and deallocate the cursor.
CLOSE curIndexes;
DEALLOCATE curIndexes;

IF EXISTS (SELECT * FROM @work_to_do)
BEGIN
    PRINT 'Estimated number of pages in fragmented indexes: ' + cast(@numpages as nvarchar(20))
    SELECT @numpages = @numpages - sum(ps.used_page_count)
    FROM
        @work_to_do AS fi
        INNER JOIN sys.indexes AS i ON fi.objectid = i.object_id and fi.indexid = i.index_id
        INNER JOIN sys.dm_db_partition_stats AS ps on i.object_id = ps.object_id and i.index_id = ps.index_id
    PRINT 'Estimated number of pages freed: ' + cast(@numpages as nvarchar(20))
END
GO

--Update all statistics
PRINT 'Updating all statistics.' + convert(nvarchar, getdate(), 121)
EXEC sp_updatestats
PRINT 'Done updating statistics.' + convert(nvarchar, getdate(), 121)
GO
"@
    Write-Verbose "Create a file with the content of the WSUSDBMaintenance Script above in the same working directory as this PowerShell script is running."
    $WSUSCleanWSUSDBMaintenanceSQLScriptFile = "$WSUSCleanScriptPath\WSUSCleanWSUSDBMaintenance.sql"
    $WSUSCleanWSUSDBMaintenanceSQLScript | Out-File "$WSUSCleanWSUSDBMaintenanceSQLScriptFile"

    # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
    $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
    Write-Verbose "Execute the SQL Script and store the results in a variable."
    $WSUSCleanWSUSDBMaintenanceSQLScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanWSUSDBMaintenanceSQLScriptFile`" -I")
    Write-Verbose "`$WSUSCleanWSUSDBMaintenanceSQLScriptJobCommand = $WSUSCleanWSUSDBMaintenanceSQLScriptJobCommand"
    $WSUSCleanWSUSDBMaintenanceSQLScriptJob = Start-Job -ScriptBlock $WSUSCleanWSUSDBMaintenanceSQLScriptJobCommand
    Wait-Job $WSUSCleanWSUSDBMaintenanceSQLScriptJob
    $WSUSCleanWSUSDBMaintenanceSQLScriptJobOutput = Receive-Job $WSUSCleanWSUSDBMaintenanceSQLScriptJob
    Remove-Job $WSUSCleanWSUSDBMaintenanceSQLScriptJob
    Write-Verbose "Remove the SQL Script file."
    Remove-Item "$WSUSCleanWSUSDBMaintenanceSQLScriptFile"
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning
    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    if ($NoOutput -eq $False) {
        $Script:WSUSCleanWSUSDBMaintenanceOutputTXT += "WSUSClean WSUS DB Maintenance:`r`n`r`n"
        $Script:WSUSCleanWSUSDBMaintenanceOutputTXT += $WSUSCleanWSUSDBMaintenanceSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n"
        $Script:WSUSCleanWSUSDBMaintenanceOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean WSUS DB Maintenance:</span></p>`n`n"
        $Script:WSUSCleanWSUSDBMaintenanceOutputHTML += $WSUSCleanWSUSDBMaintenanceSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n"
     } else {
        $Script:WSUSCleanWSUSDBMaintenanceOutputTXT += "WSUSClean WSUS DB Maintenance:`r`n`r`n"
        $Script:WSUSCleanWSUSDBMaintenanceOutputTXT += "The WSUSClean WSUS DB Maintenance Stream was run with the -NoOutput switch.`r`n"
        $Script:WSUSCleanWSUSDBMaintenanceOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean WSUS DB Maintenance:</span></p>`n`n"
        $Script:WSUSCleanWSUSDBMaintenanceOutputHTML += "<p>The WSUSClean WSUS DB Maintenance Stream was run with the -NoOutput switch.</p>`n`n"
     }
     $Script:WSUSCleanWSUSDBMaintenanceOutputTXT += "WSUS DB Maintenance Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
     $Script:WSUSCleanWSUSDBMaintenanceOutputHTML += "<p>WSUS DB Maintenance Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanWSUSDBMaintenanceOutputTXT
    # $WSUSCleanWSUSDBMaintenanceOutputHTML
}
#endregion WSUSDBMaintenance Function

#region CleanUpWSUSSynchronizationLogs Function
################################
#        Clean Up WSUS         #
# Synchronization Logs Stream  #
################################

function CleanUpWSUSSynchronizationLogs {
    Param(
    [Int]$ConsistencyNumber,
    [String]$ConsistencyTime,
    [Switch]$All
    )
  $DateNow = Get-Date
  $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScript = @"
/*
################################
#  WSUSClean WSUS Synchronization  #
#      Cleanup SQL Script      #
#       Version 1.0            #
#  Taken from various sources  #
#      from the Internet.      #
#                              #
#  Modified By: WSUS Cleanup  #
#     http://www.WSUSClean.org     #
################################
*/
$(
    if ($ConsistencyNumber -ne "0") {
    $("
USE SUSDB
GO
DELETE FROM tbEventInstance WHERE EventNamespaceID = '2' AND EVENTID IN ('381', '382', '384', '386', '387', '389') AND DATEDIFF($($ConsistencyTime), TimeAtServer, CURRENT_TIMESTAMP) >= $($ConsistencyNumber);
GO")
}
elseif ($All -ne $False) {
$("USE SUSDB
GO
DELETE FROM tbEventInstance WHERE EventNamespaceID = '2' AND EVENTID IN ('381', '382', '384', '386', '387', '389')
GO")
}
)
"@
    Write-Verbose "Create a file with the content of the WSUSCleanCleanUpWSUSSynchronizationLogs Script above in the same working directory as this PowerShell script is running."
    $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptFile = "$WSUSCleanScriptPath\WSUSCleanCleanUpWSUSSynchronizationLogs.sql"
    $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScript | Out-File "$WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptFile"
    # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
    $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
    Write-Verbose "Execute the SQL Script and store the results in a variable."
    $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptFile`" -I")
    Write-Verbose "`$WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJobCommand = $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJobCommand"
    $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJob = Start-Job -ScriptBlock $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJobCommand
    Wait-Job $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJob
    $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJobOutput = Receive-Job $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJob
    Remove-Job $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJob
    Write-Verbose "Remove the SQL Script file."
    Remove-Item "$WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptFile"
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning

    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    $Script:WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputTXT += "WSUSClean Clean Up WSUS Synchronization Logs:`r`n`r`n"
    $Script:WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputTXT += $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","`r`n"
    $Script:WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputTXT += "Clean Up WSUS Synchronization Logs Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    $Script:WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Clean Up WSUS Synchronization Logs:</span></p>`r`n"
    $Script:WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputHTML += $WSUSCleanCleanUpWSUSSynchronizationLogsSQLScriptJobOutput.Trim() -creplace'(?m)^\s*\r?\n','' -creplace '$?',"" -creplace "$","<br>`r`n"
    $Script:WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputHTML += "<p>Clean Up WSUS Synchronization Logs Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputTXT
    # $WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputHTML
}
#endregion CleanUpWSUSSynchronizationLogs Function

#region DirtyDatabaseCheck Function
################################
#  WSUSClean Dirty Database Check  #
#           Stream             #
################################

function DirtyDatabaseCheck {
    param (
    )
    $DateNow = Get-Date
    $WSUSCleanDirtyDatabaseCheckSQLScript = @"
/*
################################
#  WSUSClean Dirty Database Check  #
#          SQL Script          #
#          Version 1.0         #
#                              #
#       By: WSUS Cleanup      #
#     http://www.WSUSClean.org     #
################################
*/
USE SUSDB
select TotalResults = Count(*)
from tbFile
where (IsEncrypted = 1 and DecryptionKey is NULL) OR ((FileName like '%.esd' and IsEncrypted = 0) and DecryptionKey is NOT NULL) OR ((FileName like '%.esd' and IsEncrypted = 0) AND (FileName not like '%10586%.esd'))
"@
    Write-Verbose "Create a file with the content of the DirtyDatabaseCheck Script above in the same working directory as this PowerShell script is running."
    $WSUSCleanDirtyDatabaseCheckSQLScriptFile = "$WSUSCleanScriptPath\WSUSCleanDirtyDatabaseCheck.sql"
    $WSUSCleanDirtyDatabaseCheckSQLScript | Out-File "$WSUSCleanDirtyDatabaseCheckSQLScriptFile"
    # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
    $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
    Write-Verbose "Execute the SQL Script and store the results in a variable."
    $WSUSCleanDirtyDatabaseCheckSQLScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanDirtyDatabaseCheckSQLScriptFile`" -I")
    Write-Verbose "`$WSUSCleanDirtyDatabaseCheckSQLScriptJobCommand = $WSUSCleanDirtyDatabaseCheckSQLScriptJobCommand"
    $WSUSCleanDirtyDatabaseCheckSQLScriptJob = Start-Job -ScriptBlock $WSUSCleanDirtyDatabaseCheckSQLScriptJobCommand
    Wait-Job $WSUSCleanDirtyDatabaseCheckSQLScriptJob
    $WSUSCleanDirtyDatabaseCheckSQLScriptJobOutput = Receive-Job $WSUSCleanDirtyDatabaseCheckSQLScriptJob
    Remove-Job $WSUSCleanDirtyDatabaseCheckSQLScriptJob
    Write-Verbose "Remove the SQL Script file."
    Remove-Item "$WSUSCleanDirtyDatabaseCheckSQLScriptFile"
    if ($WSUSCleanDirtyDatabaseCheckSQLScriptJobOutput.Trim()[3] -eq "0") {
        Write-Output "You have a clean database."
        $WSUSCleanDirtyDatabaseCheckOutputTXT = "You have a clean database."
    } else {
        Write-Output 'You have a dirty database. Please see: https://support.microsoft.com/en-us/help/3194588 for more information about it.'
        $WSUSCleanDirtyDatabaseFixOutput ="You have a dirty database. Please see: https://support.microsoft.com/en-us/help/3194588 for more information about it."
        Write-Output "First we need to install the WSUS Index Optimization so that this doesn't take as long."
        $WSUSCleanDirtyDatabaseFixOutput += "First we need to install the WSUS Index Optimization so that this doesn't take as long."
        WSUSIndexOptimization
        Write-Output $WSUSCleanWSUSIndexOptimizationOutputTXT
        $WSUSCleanDirtyDatabaseFixOutput += "Now we need to run the WSUS DB Maintenance on the database to make sure we're starting with an optimized database."
        Write-Output "Now we need to run the WSUS DB Maintenance on the database to make sure we're starting with an optimized database."
        WSUSDBMaintenance
        Write-Output "Done. Now let's begin cleansing your database."
        $WSUSCleanDirtyDatabaseFixOutput += "Done. Now let's begin cleansing your database."
        Write-Output "Attempting to fix your database by the methods Microsoft recommends but augmented for future-proofing..."
        $WSUSCleanDirtyDatabaseFixOutput += "Attempting to fix your database by the methods Microsoft recommends but augmented for future-proofing..."
        Write-Verbose "First let's disable the 'Upgrades' Classification"
        Get-WsusClassification | Where-Object -FilterScript {$_.Classification.Title -Eq "Upgrades"} | Set-WsusClassification -Disable
        Write-Verbose "Create an update scope"
        $UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
        Write-Verbose "Set the update scope to 'Any' approval states"
        $UpdateScope.ApprovedStates = "Any"
        Write-Verbose "Get all updates that do not match 1511 or 1507, but do have 'Windows 10' in the title and stick them into a variable."
        $WSUSCleanDirtyDatabaseUpdates = $WSUSCleanWSUSServerAdminProxy.GetUpdates($UpdateScope) | Where-Object { -not($_.Title -match '1511' -or $_.Title -match '1507') -and ($_.Title -imatch 'Windows 10') }
        Write-Verbose "Let's decline them all"
        $WSUSCleanDirtyDatabaseUpdates | foreach { $_.Decline() }
        Write-Verbose "Let's remove them from the WSUS Server"
        $WSUSCleanDirtyDatabaseUpdates | foreach { $WSUSCleanWSUSServerAdminProxy.DeleteUpdate($_.Id.UpdateId) }
        Write-Verbose "Now let's re-enable the 'Upgrades' Classification"
        Get-WsusClassification | Where-Object -FilterScript {$_.Classification.Title -Eq "Upgrades"} | Set-WsusClassification
        Write-Verbose "We need to run a SQL Script to remove these files from the WSUS metadata"
        $WSUSCleanDirtyDatabaseFixSQLScript =@"
/*
################################
#   WSUSClean Dirty Database Fix   #
#          SQL Script          #
#          Version 1.1         #
#                              #
#       By: WSUS Cleanup      #
#     http://www.WSUSClean.org     #
################################
*/
use SUSDB
declare @NotNeededFiles table (FileDigest binary(20) UNIQUE);
insert into @NotNeededFiles(FileDigest) (select FileDigest from tbFile where FileName like '%.esd' and (FileName not like '%10240%.esd' or FileName not like '%10586%.esd') except select FileDigest from tbFileForRevision);
delete from tbFileOnServer where FileDigest in (select FileDigest from @NotNeededFiles)
delete from tbFile where FileDigest in (select FileDigest from @NotNeededFiles)
"@
        $WSUSCleanDirtyDatabaseFixSQLScriptFile = "$WSUSCleanScriptPath\WSUSCleanDirtyDatabaseCheck.sql"
        $WSUSCleanDirtyDatabaseFixSQLScript | Out-File "$WSUSCleanDirtyDatabaseFixSQLScriptFile"
        # Re-jig the $WSUSCleanSQLConnectCommand to replace the $ with a `$ for Windows 2008 Internal Database possiblity.
        $WSUSCleanSQLConnectCommand = $WSUSCleanSQLConnectCommand.Replace('$','`$')
        Write-Verbose "Execute the SQL Script and store the results in a variable."
        $WSUSCleanDirtyDatabaseFixSQLScriptJobCommand = [scriptblock]::create("$WSUSCleanSQLConnectCommand -i `"$WSUSCleanDirtyDatabaseFixSQLScriptFile`" -I")
        Write-Verbose "`$WSUSCleanDirtyDatabaseFixSQLScriptJobCommand = $WSUSCleanDirtyDatabaseFixSQLScriptJobCommand"
        $WSUSCleanDirtyDatabaseFixSQLScriptJob = Start-Job -ScriptBlock $WSUSCleanDirtyDatabaseFixSQLScriptJobCommand
        Wait-Job $WSUSCleanDirtyDatabaseFixSQLScriptJob
        $WSUSCleanDirtyDatabaseFixSQLScriptJobOutput = Receive-Job $WSUSCleanDirtyDatabaseFixSQLScriptJob
        Remove-Job $WSUSCleanDirtyDatabaseFixSQLScriptJob
        Write-Output $WSUSCleanDirtyDatabaseFixSQLScriptJobOutput
        $WSUSCleanDirtyDatabaseFixOutput += $WSUSCleanDirtyDatabaseFixSQLScriptJobOutput
        Write-Verbose "Remove the SQL Script file."
        Remove-Item "$WSUSCleanDirtyDatabaseFixSQLScriptFile"
        Write-Verbose "Finally, let's re-syncronize the server with Microsoft to pull down the updates again"
        $($WSUSCleanWSUSServerAdminProxy.GetSubscription()).StartSynchronization()
        Write-Output "Your WSUS server has been fixed. A syncronization has been initialized. Please wait while it finishes. You can monitor it through the WSUS Console."
        $WSUSCleanDirtyDatabaseFixOutput += "Your WSUS server has been fixed. A syncronization has been initialized. Please wait while it finishes. You can monitor it through the WSUS Console."
        $WSUSCleanDirtyDatabaseFixOutputTXT = $WSUSCleanDirtyDatabaseFixOutput
    }
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning

    $Script:WSUSCleanDirtyDatabaseOutputTXT = "WSUSClean Dirty Database Check Stream:`r`n`r`n"
    $Script:WSUSCleanDirtyDatabaseOutputTXT += if ([string]::isnullorempty($WSUSCleanDirtyDatabaseCheckOutputTXT)) { $WSUSCleanDirtyDatabaseFixOutputTXT + "`r`n`r`n" } else { $WSUSCleanDirtyDatabaseCheckOutputTXT + "`r`n`r`n" }
    $Script:WSUSCleanDirtyDatabaseOutputTXT += "WSUSClean Dirty Database Check Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    $Script:WSUSCleanDirtyDatabaseOutputHTML = "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Dirty Database Check Stream:</span></p>`r`n"
    $Script:WSUSCleanDirtyDatabaseOutputHTML += if ([string]::isnullorempty($WSUSCleanDirtyDatabaseCheckOutputTXT)) { $WSUSCleanDirtyDatabaseFixOutputTXT -creplace '\r\n', "<br>`r`n" -creplace '^',"<p>" -creplace '$', "</p>`r`n" } else { $WSUSCleanDirtyDatabaseCheckOutputTXT -creplace '\r\n', "<br>`r`n" -creplace '^',"<p>" -creplace '$', "</p>`r`n" }
    $Script:WSUSCleanDirtyDatabaseOutputHTML += "<p>WSUSClean Dirty Database Check Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanDirtyDatabaseOutputTXT
    # $WSUSCleanDirtyDatabaseOutputHTML
}
#endregion DirtyDatabaseCheck Function

#region ComputerObjectCleanup Function
################################
#   Computer Object Cleanup    #
#            Stream            #
################################

function ComputerObjectCleanup {
    $DateNow = Get-Date
    Write-Verbose "Create a new timespan using `$WSUSCleanComputerObjectCleanupSearchDays and find how many computers need to be cleaned up"
    $WSUSCleanComputerObjectCleanupSearchTimeSpan = New-Object timespan($WSUSCleanComputerObjectCleanupSearchDays,0,0,0)
    $WSUSCleanComputerObjectCleanupScope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
    $WSUSCleanComputerObjectCleanupScope.ToLastSyncTime = [DateTime]::UtcNow.Subtract($WSUSCleanComputerObjectCleanupSearchTimeSpan)
    $WSUSCleanComputerObjectCleanupSet = $WSUSCleanWSUSServerAdminProxy.GetComputerTargets($WSUSCleanComputerObjectCleanupScope) | Sort-Object FullDomainName
    Write-Verbose "Clean up $($WSUSCleanComputerObjectCleanupSet.Count) computer objects"
    $WSUSCleanWSUSServerAdminProxy.GetComputerTargets($WSUSCleanComputerObjectCleanupScope) | ForEach-Object { $_.Delete() }

    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning

    # Setup variables to store the output to be added at the very end of the script for logging purposes.
    $Script:WSUSCleanComputerObjectCleanupOutputTXT += "WSUSClean Computer Object Cleanup:`r`n`r`n"
    if ($($WSUSCleanComputerObjectCleanupSet.Count) -gt "0") {
        $Script:WSUSCleanComputerObjectCleanupOutputTXT += "The following $($WSUSCleanComputerObjectCleanupSet.Count) $(if ($($WSUSCleanComputerObjectCleanupSet.Count) -eq "1") { "computer" } else { "computers" }) have been removed."
        $Script:WSUSCleanComputerObjectCleanupOutputTXT += $WSUSCleanComputerObjectCleanupSet | Select-Object FullDomainName,@{Expression="   "},LastSyncTime | Format-Table -AutoSize | Out-String
    } else { $Script:WSUSCleanComputerObjectCleanupOutputTXT += "There are no computers to clean up.`r`n" }

    $Script:WSUSCleanComputerObjectCleanupOutputTXT += "WSUSClean Computer Object Cleanup Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanComputerObjectCleanupOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean Computer Object Cleanup:</span></p>`r`n"
    if ($($WSUSCleanComputerObjectCleanupSet.Count) -gt "0") {
        $Script:WSUSCleanComputerObjectCleanupOutputHTML += "<p>The following $($WSUSCleanComputerObjectCleanupSet.Count) $(if ($($WSUSCleanComputerObjectCleanupSet.Count) -eq "1") { "computer" } else { "computers" }) have been removed.</p>"
        $Script:WSUSCleanComputerObjectCleanupOutputHTML += ($WSUSCleanComputerObjectCleanupSet | Select-Object FullDomainName,LastSyncTime | ConvertTo-Html -Fragment) -replace "\<table\>",'<table class="gridtable">'
    } else { $Script:WSUSCleanComputerObjectCleanupOutputHTML += "<p>There are no computers to clean up.</p>" }
    $Script:WSUSCleanComputerObjectCleanupOutputHTML += "<p>WSUSClean Computer Object Cleanup Stream Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    # Variables Output
    # $WSUSCleanComputerObjectCleanupOutputTXT
    # $WSUSCleanComputerObjectCleanupOutputHTML
}

#endregion ComputerObjectCleanup Function

#region WSUSServerCleanupWizard Function
################################
#  WSUS Server Cleanup Wizard  #
#            Stream            #
################################

function WSUSServerCleanupWizard {
    $DateNow = Get-Date
    $WSUSServerCleanupWizardBody = "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUS Server Cleanup Wizard:</span></p>" | Out-String
    $CleanupManager = $WSUSCleanWSUSServerAdminProxy.GetCleanupManager();
    $CleanupScope = New-Object Microsoft.UpdateServices.Administration.CleanupScope ($WSUSCleanSCWSupersededUpdatesDeclined,$WSUSCleanSCWExpiredUpdatesDeclined,$WSUSCleanSCWObsoleteUpdatesDeleted,$WSUSCleanSCWUpdatesCompressed,$WSUSCleanSCWObsoleteComputersDeleted,$WSUSCleanSCWUnneededContentFiles);
    $WSUSCleanCleanupResults = $CleanupManager.PerformCleanup($CleanupScope)
    $FinishedRunning = Get-Date
    $DifferenceInTime = New-TimeSpan -Start $DateNow -End $FinishedRunning

    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "WSUSClean WSUS Server Cleanup Wizard:`r`n`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "$WSUSCleanWSUSServer`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "Version: $($WSUSCleanWSUSServerAdminProxy.Version)`r`n"
    #$Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "Started: $($DateNow.ToString("yyyy.MM.dd hh:mm:ss tt zzz"))`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "SupersededUpdatesDeclined: $($WSUSCleanCleanupResults.SupersededUpdatesDeclined)`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "ExpiredUpdatesDeclined: $($WSUSCleanCleanupResults.ExpiredUpdatesDeclined)`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "ObsoleteUpdatesDeleted: $($WSUSCleanCleanupResults.ObsoleteUpdatesDeleted)`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "UpdatesCompressed: $($WSUSCleanCleanupResults.UpdatesCompressed)`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "ObsoleteComputersDeleted: $($WSUSCleanCleanupResults.ObsoleteComputersDeleted)`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "DiskSpaceFreed (MB): $([math]::round($WSUSCleanCleanupResults.DiskSpaceFreed/1MB, 2))`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "DiskSpaceFreed (GB): $([math]::round($WSUSCleanCleanupResults.DiskSpaceFreed/1GB, 2))`r`n"
    #$Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "Finished: $($FinishedRunning.ToString("yyyy.MM.dd hh:mm:ss tt zzz"))`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputTXT += "WSUS Server Cleanup Wizard Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})

    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<p><span style=`"font-weight: bold; font-size: 1.2em;`">WSUSClean WSUS Server Cleanup Wizard:</span></p>`r`n"
    #$Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += $WSUSCleanCSSStyling + "`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<table class=`"gridtable`">`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tbody>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><th colspan=`"2`" rowspan=`"1`">$WSUSCleanWSUSServer</th></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>Version:</td><td>$($WSUSCleanWSUSServerAdminProxy.Version)</td></tr>`r`n"
    #$Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>Started:</td><td>$($DateNow.ToString("yyyy.MM.dd hh:mm:ss tt zzz"))</td></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>SupersededUpdatesDeclined:</td><td>$($WSUSCleanCleanupResults.SupersededUpdatesDeclined)</td></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>ExpiredUpdatesDeclined:</td><td>$($WSUSCleanCleanupResults.ExpiredUpdatesDeclined)</td></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>ObsoleteUpdatesDeleted:</td><td>$($WSUSCleanCleanupResults.ObsoleteUpdatesDeleted)</td></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>UpdatesCompressed:</td><td>$($WSUSCleanCleanupResults.UpdatesCompressed)</td></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>ObsoleteComputersDeleted:</td><td>$($WSUSCleanCleanupResults.ObsoleteComputersDeleted)</td></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>DiskSpaceFreed (MB):</td><td>$([math]::round($WSUSCleanCleanupResults.DiskSpaceFreed/1MB, 2))</td></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>DiskSpaceFreed (GB):</td><td>$([math]::round($WSUSCleanCleanupResults.DiskSpaceFreed/1GB, 2))</td></tr>`r`n"
    #$Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>Finished:</td><td>$($FinishedRunning.ToString("yyyy.MM.dd hh:mm:ss tt zzz"))</td></tr>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "<tr><td>WSUS Server Cleanup Wizard Duration:</td><td>{0:00}:{1:00}:{2:00}:{3:00}</td></tr>`r`n" -f ($DifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "</tbody>`r`n"
    $Script:WSUSCleanWSUSServerCleanupWizardOutputHTML += "</table>`r`n"

    # Variables Output
    # $WSUSCleanWSUSServerCleanupWizardOutputTXT
    # $WSUSCleanWSUSServerCleanupWizardOutputHTML
}
#endregion WSUSServerCleanupWizard Function

#region WSUSCleanScriptDifferenceInTime Function
function WSUSCleanScriptDifferenceInTime {
    $WSUSCleanScriptFinishedRunning = Get-Date
    $Script:WSUSCleanScriptDifferenceInTime = New-TimeSpan -Start $WSUSCleanScriptTime -End $WSUSCleanScriptFinishedRunning
}
#endregion WSUSCleanScriptDifferenceInTime Function

#region Create The CSS Styling
################################
#    Create the CSS Styling    #
################################

$WSUSCleanCSSStyling =@"
<style type="text/css">
#gridtable table, table.gridtable {
    font-family: verdana,arial,sans-serif;
    font-size: 11px;
    color: #333333;
    border-width: 1px;
    border-color: #666666;
    border-collapse: collapse;
}
#gridtable table th, table.gridtable th {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #dedede;
}
#gridtable table td, table.gridtable td {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #ffffff;
}
.TFtable{
    border-collapse:collapse;
}
.TFtable td{
    padding:7px;
    border:#4e95f4 1px solid;
}

/* provide some minimal visual accommodation for IE8 and below */
.TFtable tr{
    background: #b8d1f3;
}
/* Define the background color for all the ODD background rows */
.TFtable tr:nth-child(odd){
    background: #b8d1f3;
}
/* Define the background color for all the EVEN background rows */
.TFtable tr:nth-child(even){
    background: #dae5f4;
}
.error {
border: 2px solid;
margin: 10px 10px;
padding: 15px 50px 15px 50px;
}
.error ol {
color: #D8000C;
}
.error ol li p {
color: #000;
background-color: transparent;
}
.error ol li {
background-color: #FFBABA;
margin: 10px 0;
}
</style>
"@
#endregion Create The CSS Styling

#region Create The Output
################################
#     Create the TXT output    #
################################

function CreateBodyTXT {
    $Script:WSUSCleanBodyTXT = "`n"
    $Script:WSUSCleanBodyTXT += $WSUSCleanBodyHeaderTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanConnectedTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanWSUSIndexOptimizationOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanRemoveObsoleteUpdatesOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanCompressUpdateRevisionsOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanDeclineMultipleTypesOfUpdatesOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanRemoveWSUSDriversOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanRemoveDeclinedWSUSUpdatesOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanComputerObjectCleanupOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanWSUSDBMaintenanceOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanWSUSServerCleanupWizardOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanInstallTaskOutputTXT
    $Script:WSUSCleanBodyTXT += $WSUSCleanDirtyDatabaseOutputTXT
    $Script:WSUSCleanBodyTXT += "`r`nClean-WSUS Script Duration: {0:00}:{1:00}:{2:00}:{3:00}`r`n`r`n" -f ($WSUSCleanScriptDifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanBodyTXT += $WSUSCleanBodyFooterTXT
}

################################
#    Create the HTML output    #
################################

function CreateBodyHTML {
    $Script:WSUSCleanBodyHTML = "`n"
    $Script:WSUSCleanBodyHTML += $WSUSCleanCSSStyling
    $Script:WSUSCleanBodyHTML += $WSUSCleanBodyHeaderHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanConnectedHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanWSUSIndexOptimizationOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanRemoveObsoleteUpdatesOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanCompressUpdateRevisionsOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanDeclineMultipleTypesOfUpdatesOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanCleanUpWSUSSynchronizationLogsSQLOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanRemoveWSUSDriversOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanRemoveDeclinedWSUSUpdatesOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanComputerObjectCleanupOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanWSUSDBMaintenanceOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanWSUSServerCleanupWizardOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanInstallTaskOutputHTML
    $Script:WSUSCleanBodyHTML += $WSUSCleanDirtyDatabaseOutputHTML
    $Script:WSUSCleanBodyHTML += "<p>Clean-WSUS Script Duration: {0:00}:{1:00}:{2:00}:{3:00}</p>`r`n" -f ($WSUSCleanScriptDifferenceInTime | % {$_.Days, $_.Hours, $_.Minutes, $_.Seconds})
    $Script:WSUSCleanBodyHTML += $WSUSCleanBodyFooterHTML
}
#endregion Create The Output

#region SaveReport
################################
#       Save the Report        #
################################

function SaveReport {
    Param(
    [ValidateSet("TXT","HTML")]
    [String]$ReportType = "TXT"
    )
    if ($ReportType -eq "HTML") {
        $WSUSCleanBodyHTML | Out-File -FilePath "$WSUSCleanScriptPath\$(get-date -f "yyyy.MM.dd-HH.mm.ss").htm"
    } else {
        $WSUSCleanBodyTXT | Out-File -FilePath "$WSUSCleanScriptPath\$(get-date -f "yyyy.MM.dd-HH.mm.ss").txt"
    }
}
#endregion SaveReport

#region MailReport
################################
#       Mail the Report        #
################################

function MailReport {
    param (
        [ValidateSet("TXT","HTML")]
        [String] $MessageContentType = "HTML"
    )
    $message = New-Object System.Net.Mail.MailMessage
    $mailer = New-Object System.Net.Mail.SmtpClient ($WSUSCleanMailReportSMTPServer, $WSUSCleanMailReportSMTPPort)
    $mailer.EnableSSL = $WSUSCleanMailReportSMTPServerEnableSSL
    if ($WSUSCleanMailReportSMTPServerUsername -ne "") {
        $mailer.Credentials = New-Object System.Net.NetworkCredential($WSUSCleanMailReportSMTPServerUsername, $WSUSCleanMailReportSMTPServerPassword)
    }
    $message.From = $WSUSCleanMailReportEmailFromAddress
    $message.To.Add($WSUSCleanMailReportEmailToAddress)
    $message.Subject = $WSUSCleanMailReportEmailSubject
    $message.Body = if ($MessageContentType -eq "HTML") { $WSUSCleanBodyHTML } else { $WSUSCleanBodyTXT }
    $message.IsBodyHtml = if ($MessageContentType -eq "HTML") { $True } else { $False }
    $mailer.send(($message))
}
#endregion MailReport

#region HelpMe
################################
#           Help Me            #
################################

function HelpMe {
    ((Get-CimInstance Win32_OperatingSystem) | Format-List @{Name="OS Name";Expression={$_.Caption}}, @{Name="OS Architecture";Expression={$_.OSArchitecture}}, @{Name="Version";Expression={$_.Version}}, @{Name="ServicePackMajorVersion";Expression={$_.ServicePackMajorVersion}}, @{Name="ServicePackMinorVersion";Expression={$_.ServicePackMinorVersion}} | Out-String).Trim()
    Write-Output "PowerShell Version: $($PSVersionTable.PSVersion.ToString())"
    Write-Output "WSUS Version: $($WSUSCleanWSUSServerAdminProxy.Version)"
    Write-Output "Replica Server: $($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer)"
    Write-Output "The path to the WSUS Content folder is: $($WSUSCleanWSUSServerAdminProxy.GetConfiguration().LocalContentCachePath)"
    Write-Output "Free Space on the WSUS Content folder Volume is: $((Get-DiskFree -Format | ? { $_.Type -like '*fixed*' } | Where-Object { ($_.Vol -eq ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().LocalContentCachePath).split("\")[0]) }).Avail)"
    Write-Output "All Volumes on the WSUS Server:"
    (Get-DiskFree -Format | Out-String).Trim()
    Write-Output ".NET Installed Versions"
    (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version -EA 0 | Where { $_.PSChildName -Match '^(?!S)\p{L}'} | Format-Table PSChildName, Version -AutoSize | Out-String).Trim()
    Write-Output "============================="
    Write-Output "All My Functions"
    Write-Output "============================="
    Show-MyFunctions
    Write-Output "============================="
    Write-Output "All My Variables"
    Write-Output "============================="
    Show-MyVariables
    Write-Output "============================="
    Write-Output " End of HelpMe Stream"
    Write-Output "============================="

}
#endregion HelpMe

#region Process The Functions
################################
#    Process the Functions     #
################################

if ($FirstRun -eq $True) {
    CreateWSUSCleanHeader
    Write-Output "Executing WSUSIndexOptimization"; WSUSIndexOptimization
    if ($WSUSCleanRemoveWSUSDriversInFirstRun -eq $True) { Write-Output "Executing RemoveWSUSDrivers"; RemoveWSUSDrivers -SQL }
    Write-Output "Executing RemoveObsoleteUpdates"; RemoveObsoleteUpdates
    Write-Output "Executing CompressUpdateRevisions"; CompressUpdateRevisions
    Write-Output "Executing DeclineMultipleTypesOfUpdates"; if ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineMultipleTypesOfUpdates -Force } else { Write-Output "This WSUS Server is a Replica Server. You can't decline updates from a replica server. Skipping this stream." }
    Write-Output "Executing CleanUpWSUSSynchronizationLogs"; if ($WSUSCleanCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyTime }
    if ($WSUSCleanComputerObjectCleanup -eq $True) { Write-Output "Executing ComputerObjectCleanup"; ComputerObjectCleanup }
    Write-Output "Executing WSUSDBMaintenance"; WSUSDBMaintenance
    Write-Output "Executing WSUSServerCleanupWizard"; WSUSServerCleanupWizard
    Write-Output "Executing Install-Task"; Install-Task;
    CreateWSUSCleanFooter
    WSUSCleanScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    if ($WSUSCleanMailReport -eq $True) { MailReport $WSUSCleanMailReportType }
    SaveReport

}
if ($MonthlyRun -eq $True) {
    CreateWSUSCleanHeader
    Write-Output "Executing RemoveObsoleteUpdates"; RemoveObsoleteUpdates
    Write-Output "Executing CompressUpdateRevisions"; CompressUpdateRevisions
    Write-Output "Executing DeclineMultipleTypesOfUpdates"; if ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineMultipleTypesOfUpdates -Force } else { Write-Output "This WSUS Server is a Replica Server. You can't decline updates from a replica server. Skipping this stream." }
    Write-Output "Executing CleanUpWSUSSynchronizationLogs"; if ($WSUSCleanCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyTime }
    if ($WSUSCleanComputerObjectCleanup -eq $True) { Write-Output "Executing ComputerObjectCleanup"; ComputerObjectCleanup }
    Write-Output "Executing WSUSDBMaintenance"; WSUSDBMaintenance
    Write-Output "Executing WSUSServerCleanupWizard"; WSUSServerCleanupWizard
    CreateWSUSCleanFooter
    WSUSCleanScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    if ($WSUSCleanMailReport -eq $True) { MailReport $WSUSCleanMailReportType }
    if ($WSUSCleanSaveReport -eq $True) { SaveReport $WSUSCleanSaveReportType }
}
if ($QuarterlyRun -eq $True) {
    CreateWSUSCleanHeader
    Write-Output "Executing RemoveObsoleteUpdates"; RemoveObsoleteUpdates
    Write-Output "Executing CompressUpdateRevisions"; CompressUpdateRevisions
    Write-Output "Executing DeclineMultipleTypesOfUpdates"; if ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineMultipleTypesOfUpdates -Force } else { Write-Output "This WSUS Server is a Replica Server. You can't decline updates from a replica server. Skipping this stream." }
    Write-Output "Executing CleanUpWSUSSynchronizationLogs"; if ($WSUSCleanCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyTime }
    if ($WSUSCleanRemoveWSUSDriversInRoutines -eq $True) { Write-Output "Executing RemoveWSUSDrivers"; RemoveWSUSDrivers }
    Write-Output "Executing RemoveDeclinedWSUSUpdates"; RemoveDeclinedWSUSUpdates -Display -Proceed
    if ($WSUSCleanComputerObjectCleanup -eq $True) { Write-Output "Executing ComputerObjectCleanup"; ComputerObjectCleanup }
    Write-Output "Executing WSUSDBMaintenance"; WSUSDBMaintenance
    Write-Output "Executing WSUSServerCleanupWizard"; WSUSServerCleanupWizard
    CreateWSUSCleanFooter
    WSUSCleanScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    if ($WSUSCleanMailReport -eq $True) { MailReport $WSUSCleanMailReportType }
    if ($WSUSCleanSaveReport -eq $True) { SaveReport $WSUSCleanSaveReportType }
}
if ($ScheduledRun -eq $True) {
    $DateNow = Get-Date
    CreateWSUSCleanHeader
    if ($WSUSCleanScheduledRunStreamsDay -gt 31 -or $WSUSCleanScheduledRunStreamsDay -eq 0) { Write-Output 'You failed to set a valid value for $WSUSCleanScheduledRunStreamsDay. Setting to 31'; $WSUSCleanScheduledRunStreamsDay = 31 }
    if ($WSUSCleanScheduledRunStreamsDay -eq $DateNow.Day) { Write-Output "Executing RemoveObsoleteUpdates"; RemoveObsoleteUpdates }
    if ($WSUSCleanScheduledRunStreamsDay -eq $DateNow.Day) { Write-Output "Executing CompressUpdateRevisions"; CompressUpdateRevisions }
    Write-Output "Executing DeclineMultipleTypesOfUpdates"; if ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineMultipleTypesOfUpdates } else { Write-Output "This WSUS Server is a Replica Server. You can't decline superseded updates from a replica server. Skipping this stream."}
    Write-Output "Executing CleanUpWSUSSynchronizationLogs"; if ($WSUSCleanCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyTime }
    $WSUSCleanScheduledRunQuarterlyMonths.Split(",") | ForEach-Object {
	    if ($_ -eq $DateNow.Month) {
		    if ($_ -eq 2) {
                if ($WSUSCleanScheduledRunStreamsDay -gt 28 -and [System.DateTime]::isleapyear($DateNow.Year) -eq $True) { $WSUSCleanScheduledRunStreamsDay = 29 }
                else { $WSUSCleanScheduledRunStreamsDay = 28 }
		    }
		    if (4,6,9,11 -contains $_ -and $WSUSCleanScheduledRunStreamsDay -gt 30) { $WSUSCleanScheduledRunStreamsDay = 30 }
            if ($WSUSCleanScheduledRunStreamsDay -eq $DateNow.Day) {
			    if ($WSUSCleanRemoveWSUSDriversInRoutines -eq $True) { Write-Output "Executing RemoveWSUSDrivers"; RemoveWSUSDrivers }
			    Write-Output "Executing RemoveDeclinedWSUSUpdates"; RemoveDeclinedWSUSUpdates -Display -Proceed
		    }
	    }
    }
    if ($WSUSCleanComputerObjectCleanup -eq $True) { Write-Output "Executing ComputerObjectCleanup"; ComputerObjectCleanup }
    Write-Output "Executing WSUSDBMaintenance"; if ($WSUSCleanScheduledRunStreamsDay -eq $DateNow.Day) { WSUSDBMaintenance } else { WSUSDBMaintenance -NoOutput }
    Write-Output "Executing WSUSServerCleanupWizard"; WSUSServerCleanupWizard
    CreateWSUSCleanFooter
    WSUSCleanScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    if ($WSUSCleanMailReport -eq $True) { MailReport $WSUSCleanMailReportType }
    if ($WSUSCleanSaveReport -eq $True) { SaveReport $WSUSCleanSaveReportType }
}
if ($DailyRun -eq $True) {
    CreateWSUSCleanHeader
    Write-Output "Executing DeclineMultipleTypesOfUpdates"; if ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineMultipleTypesOfUpdates } else { Write-Output "This WSUS Server is a Replica Server. You can't decline updates from a replica server. Skipping this stream." }
    Write-Output "Executing CleanUpWSUSSynchronizationLogs"; if ($WSUSCleanCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyTime }
    if ($WSUSCleanComputerObjectCleanup -eq $True) { Write-Output "Executing ComputerObjectCleanup"; ComputerObjectCleanup }
    Write-Output "Executing WSUSDBMaintenance"; WSUSDBMaintenance
    Write-Output "Executing WSUSServerCleanupWizard"; WSUSServerCleanupWizard
    CreateWSUSCleanFooter
    WSUSCleanScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    if ($WSUSCleanMailReport -eq $True) { MailReport $WSUSCleanMailReportType }
    if ($WSUSCleanSaveReport -eq $True) { SaveReport $WSUSCleanSaveReportType }
}
if (-not $FirstRun -and -not $MonthlyRun -and -not $QuarterlyRun -and -not $ScheduledRun -and -not $DailyRun) {
    Write-Verbose "All pre-defined routines (-FirstRun, -DailyRun, -MonthlyRun, -QuarterlyRun, -ScheduledRun) were not specified"
    CreateWSUSCleanHeader
    if ($WSUSIndexOptimization -eq $True) { Write-Output "Executing WSUSIndexOptimization"; WSUSIndexOptimization }
    if ($RemoveWSUSDriversSQL -eq $True) { Write-Output "Executing RemoveWSUSDrivers using SQL"; RemoveWSUSDrivers -SQL }
    if ($RemoveWSUSDriversPS -eq $True) { Write-Output "Executing RemoveWSUSDrivers using PowerShell"; RemoveWSUSDrivers }
    if ($RemoveObsoleteUpdates -eq $True) { Write-Output "Executing RemoveObsoleteUpdates using SQL"; if ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { RemoveObsoleteUpdates } else { Write-Output "This WSUS Server is a Replica Server. You can't remove obsolete updates from a replica server. Skipping this stream." } }
    if ($CompressUpdateRevisions -eq $True) { Write-Output "Executing CompressUpdateRevisions using SQL"; if ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { CompressUpdateRevisions } else { Write-Output "This WSUS Server is a Replica Server. You can't compress update revisions from a replica server. Skipping this stream." } }
    if ($DeclineMultipleTypesOfUpdates -eq $True) { Write-Output "Executing DeclineMultipleTypesOfUpdates"; if ($WSUSCleanWSUSServerAdminProxy.GetConfiguration().IsReplicaServer -eq $False) { DeclineMultipleTypesOfUpdates -Force } else { Write-Output "This WSUS Server is a Replica Server. You can't decline updates from a replica server. Skipping this stream." } }
    if ($CleanUpWSUSSynchronizationLogs -eq $True) { Write-Output "Executing CleanUpWSUSSynchronizationLogs"; if ($WSUSCleanCleanUpWSUSSynchronizationLogsAll -eq $True) { CleanUpWSUSSynchronizationLogs -All } else { CleanUpWSUSSynchronizationLogs -ConsistencyNumber $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyNumber -ConsistencyTime $WSUSCleanCleanUpWSUSSynchronizationLogsConsistencyTime } }
    if ($RemoveDeclinedWSUSUpdates -eq $True) { Write-Output "Executing RemoveDeclinedWSUSUpdates"; RemoveDeclinedWSUSUpdates -Display -Proceed }
    if ($ComputerObjectCleanup -eq $True -and $WSUSCleanComputerObjectCleanup -eq $True) { Write-Output "Executing ComputerObjectCleanup"; ComputerObjectCleanup }
    if ($WSUSDBMaintenance -eq $True) { Write-Output "Executing WSUSDBMaintenance"; WSUSDBMaintenance }
    if ($DirtyDatabaseCheck) { Write-Output "Executing DirtyDatabaseCheck"; DirtyDatabaseCheck }
    if ($WSUSServerCleanupWizard -eq $True) { Write-Output "Executing WSUSServerCleanupWizard"; WSUSServerCleanupWizard }
    CreateWSUSCleanFooter
    WSUSCleanScriptDifferenceInTime
    CreateBodyTXT
    CreateBodyHTML
    if ($SaveReport -eq "TXT") { SaveReport }
    if ($SaveReport -eq "HTML") { SaveReport -ReportType "HTML" }
    if ($MailReport -eq "HTML") { MailReport }
    if ($MailReport -eq "TXT") { MailReport -MessageContentType "TXT" }
}

if ($HelpMe -eq $True) {
    HelpMe
}
if ($DisplayApplicationPoolMemory -eq $True) {
    ApplicationPoolMemory
}
Write-Verbose "Just before setting the application memory `$SetApplicationPoolMemory is $SetApplicationPoolMemory"
if ($SetApplicationPoolMemory -ne '-1') {
    ApplicationPoolMemory -Set $SetApplicationPoolMemory
}

if ($InstallTask -eq $True) {
    Install-Task
}
#endregion ProcessTheFunctions
}

End {
    if ($HelpMe -eq $True) { $VerbosePreference = $WSUSCleanOldVerbose; Stop-Transcript }
    Write-Verbose "End Of Code"
}
################################
#         End Of Code          #
################################
#EOF