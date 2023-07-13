<#
.SYNOPSIS
This script uses Robocopy to move or copy data between directories, including support for both local paths and UNC paths. It includes subfolders and their contents in the copy operation.

.DESCRIPTION
The script prompts the user to enter the source directory and the destination directory. It then executes Robocopy with the provided directories and copies the files and subfolders accordingly. The script supports copying from local paths to UNC paths, from UNC paths to local paths, and between UNC paths.

.PARAMETER SourceDirectory
Specifies the source directory from where the files will be copied.

.PARAMETER DestinationDirectory
Specifies the destination directory where the files will be copied to.

.PARAMETER Action
Specifies the action to perform: Move or Copy.

.NOTES
Script Name: Move-DataWithRobocopy.ps1
Created By: Your Name
Date: Enter Date
Version: 1.0

.EXAMPLE
.\Move-DataWithRobocopy.ps1
# Prompts the user to enter the source directory and destination directory, and then executes Robocopy to move or copy the files.

#>

# Prompt the user to enter the source directory
$sourceDirectory = Read-Host -Prompt "Enter the source directory (local or unc)"

# Prompt the user to enter the destination directory
$destinationDirectory = Read-Host -Prompt "Enter the destination directory (local or unc)"

# Prompt the user to choose the action: Move or Copy
$action = Read-Host -Prompt "Choose the action: Move (M) or Copy (C)"

# Validate the action input
if ($action -ne "M" -and $action -ne "C") {
    Write-Host "Invalid action. Please choose either Move (M) or Copy (C)."
    Exit
}

# Include These Files (can be modified as needed)
$includeFiles = "*.*"

# Exclude These Directories (can be modified as needed)
$excludeDirectories = ""

# Exclude These Files (can be modified as needed)
$excludeFiles = ""

# Copy options (can be modified as needed)
$copyOptions = "/COPYALL /R:1000000 /W:30"

# Retry Options (can be modified as needed)
$retryCount = 1
$retryWaitTime = 5

# Logging Options (can be modified as needed)
$logFilePath = "C:\RobocopyLog.txt"

# Prepare the source and destination paths for UNC format if needed
if ($sourceDirectory -notlike "\\*") {
    $sourceDirectory = $sourceDirectory.TrimEnd('\') # Remove trailing backslash if present
}
if ($destinationDirectory -notlike "\\*") {
    $destinationDirectory = $destinationDirectory.TrimEnd('\') # Remove trailing backslash if present
}

# Check if source or destination paths are UNC paths
$sourceIsUNC = $sourceDirectory -like "\\*"
$destinationIsUNC = $destinationDirectory -like "\\*"

# Get the parent directory name from the source path
$parentDirectory = Split-Path -Path $sourceDirectory -Leaf

# Determine the appropriate Robocopy command based on the paths and action
$robocopyCommand = if ($sourceIsUNC -and $destinationIsUNC) {
    if ($action -eq "M") {
        "robocopy `"$sourceDirectory`" `"$destinationDirectory\$parentDirectory`" $includeFiles /XD $excludeDirectories /XF $excludeFiles $copyOptions /R:$retryCount /W:$retryWaitTime /LOG:`"$logFilePath`" /TEE /V /FP /E /MOVE"
    }
    else {
        "robocopy `"$sourceDirectory`" `"$destinationDirectory\$parentDirectory`" $includeFiles /XD $excludeDirectories /XF $excludeFiles $copyOptions /R:$retryCount /W:$retryWaitTime /LOG:`"$logFilePath`" /TEE /V /FP /E"
    }
}
elseif ($sourceIsUNC) {
    if ($action -eq "M") {
        "robocopy `"$sourceDirectory`" `"$destinationDirectory\$parentDirectory`" $includeFiles /XD $excludeDirectories /XF $excludeFiles $copyOptions /R:$retryCount /W:$retryWaitTime /LOG:`"$logFilePath`" /TEE /V /FP /E /ZB /MOVE"
    }
    else {
        "robocopy `"$sourceDirectory`" `"$destinationDirectory\$parentDirectory`" $includeFiles /XD $excludeDirectories /XF $excludeFiles $copyOptions /R:$retryCount /W:$retryWaitTime /LOG:`"$logFilePath`" /TEE /V /FP /E /ZB"
    }
}
elseif ($destinationIsUNC) {
    if ($action -eq "M") {
        "robocopy `"$sourceDirectory`" `"$destinationDirectory\$parentDirectory`" $includeFiles /XD $excludeDirectories /XF $excludeFiles $copyOptions /R:$retryCount /W:$retryWaitTime /LOG:`"$logFilePath`" /TEE /V /FP /E /Z"
    }
    else {
        "robocopy `"$sourceDirectory`" `"$destinationDirectory\$parentDirectory`" $includeFiles /XD $excludeDirectories /XF $excludeFiles $copyOptions /R:$retryCount /W:$retryWaitTime /LOG:`"$logFilePath`" /TEE /V /FP /E /Z"
    }
}
else {
    if ($action -eq "M") {
        "robocopy `"$sourceDirectory`" `"$destinationDirectory\$parentDirectory`" $includeFiles /XD $excludeDirectories /XF $excludeFiles $copyOptions /R:$retryCount /W:$retryWaitTime /LOG:`"$logFilePath`" /TEE /V /FP /E /MOVE"
    }
    else {
        "robocopy `"$sourceDirectory`" `"$destinationDirectory\$parentDirectory`" $includeFiles /XD $excludeDirectories /XF $excludeFiles $copyOptions /R:$retryCount /W:$retryWaitTime /LOG:`"$logFilePath`" /TEE /V /FP /E"
    }
}

# Execute the Robocopy command
Invoke-Expression -Command $robocopyCommand